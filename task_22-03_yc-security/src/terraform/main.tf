terraform {
  required_providers {
    yandex = { source = "yandex-cloud/yandex" }
  }
}

provider "yandex" {
  cloud_id                 = "b1gg429r8vsdd2339fed"
  folder_id                = "b1gsk9lfnqfglntfchri"
  zone                     = "ru-central1-a"
  service_account_key_file = pathexpand("~/.secrets/netology/authorized_key.json")
}

resource "yandex_vpc_network" "net" {
  name = "secure-net"
}

resource "yandex_vpc_subnet" "public_a" {
  name           = "secure-public-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

resource "yandex_vpc_subnet" "public_d" {
  name           = "secure-public-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.0.2.0/24"]
}

resource "yandex_vpc_subnet" "public_e" {
  name           = "secure-public-e"
  zone           = "ru-central1-e"
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.0.3.0/24"]
}

resource "yandex_vpc_security_group" "sg_web" {
  name       = "web-security-group"
  network_id = yandex_vpc_network.net.id

  ingress {
    protocol       = "TCP"
    description    = "HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_kms_symmetric_key" "bucket_key" {
  name              = "bucket-encryption-key"
  description       = "KMS key for bucket encryption"
  default_algorithm = "AES_128"
  rotation_period   = "8760h"
}

resource "yandex_storage_bucket" "bucket" {
  bucket = "nikolay-modonov-secure-bucket"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.bucket_key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "yandex_storage_object" "picture" {
  bucket = yandex_storage_bucket.bucket.bucket
  key    = "images.jpg"
  source = "images.jpg"
}

resource "yandex_compute_instance_group" "lamp_group" {
  name               = "secure-lamp-group"
  folder_id          = "b1gsk9lfnqfglntfchri"
  service_account_id = "ajetajvuoctg8sjfsn72"

  instance_template {
    platform_id = "standard-v2"

    resources {
      cores         = 2
      memory        = 2
      core_fraction = 20
    }

    boot_disk {
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
        size     = 8
        type     = "network-hdd"
      }
    }

    network_interface {
      network_id = yandex_vpc_network.net.id
      subnet_ids = [
        yandex_vpc_subnet.public_a.id,
        yandex_vpc_subnet.public_d.id,
        yandex_vpc_subnet.public_e.id
      ]
      nat                = true
      security_group_ids = [yandex_vpc_security_group.sg_web.id]
    }

    metadata = {
      ssh-keys = "ubuntu:${file(pathexpand("~/.ssh/terraform-yc.pub"))}"
      user-data = <<-EOF
#!/bin/bash
PUBLIC_IPV4=$(curl -s ifconfig.me)
echo "<html><body><h1>Hello from $(hostname)</h1><p>IP: $PUBLIC_IPV4</p></body></html>" > /var/www/html/index.html
EOF
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = ["ru-central1-a", "ru-central1-d", "ru-central1-e"]
  }

  deploy_policy {
    max_unavailable = 1
    max_creating    = 3
    max_expansion   = 3
    max_deleting    = 3
  }

  load_balancer {
    target_group_name = "secure-lamp-target-group"
  }
}

resource "yandex_lb_network_load_balancer" "nlb" {
  name = "secure-lamp-balancer"

  listener {
    name        = "http"
    port        = 80
    target_port = 80
    protocol    = "tcp"
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.lamp_group.load_balancer.0.target_group_id

    healthcheck {
      name = "http-check"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

output "balancer_ip" {
  value = try(tolist(tolist(yandex_lb_network_load_balancer.nlb.listener)[0].external_address_spec)[0].address, null)
}