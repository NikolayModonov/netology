terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 1.12.0"
}

provider "yandex" {
  cloud_id  = "b1gg429r8vsdd2339fed"
  folder_id = "b1gsk9lfnqfglntfchri"
  zone      = "ru-central1-a"
  token     = "REMOVED_SECRET"
}

resource "yandex_vpc_network" "net" {
  name = "ansible-net"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "ansible-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

resource "yandex_vpc_subnet" "subnet_d" {
  name           = "ansible-subnet-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.0.2.0/24"]
}

data "yandex_compute_image" "debian" {
  family = "debian-12"
}

# Cloud-init для Controller (установка Ansible)
locals {
  cloud_init_controller = <<-EOF
#cloud-config
apt:
  primary:
    - arches: [default]
      uri: "http://mirror.yandex.ru/debian/"
  security:
    - arches: [default]
      uri: "http://mirror.yandex.ru/debian-security/"
package_update: true
packages:
  - python3
  - python3-pip
  - ansible
runcmd:
  - [ ansible, --version ]
EOF
}

# Cloud-init для Target (только Python для Ansible)
locals {
  cloud_init_target = <<-EOF
#cloud-config
apt:
  primary:
    - arches: [default]
      uri: "http://mirror.yandex.ru/debian/"
  security:
    - arches: [default]
      uri: "http://mirror.yandex.ru/debian-security/"
package_update: true
packages:
  - python3
  - python3-apt
runcmd:
  - [ python3, --version ]
EOF
}

resource "yandex_compute_instance" "controller" {
  name        = "ansible-controller"
  platform_id = "standard-v2"
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.debian.image_id
      size     = 10
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }
  metadata = {
    ssh-keys = "debian:${file("~/.ssh/terraform-yc.pub")}"
    user-data = local.cloud_init_controller
  }
}

resource "yandex_compute_instance" "target1" {
  name        = "target-node-1"
  platform_id = "standard-v2"
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.debian.image_id
      size     = 10
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }
  metadata = {
    ssh-keys = "debian:${file("~/.ssh/terraform-yc.pub")}"
    user-data = local.cloud_init_target
  }
}

resource "yandex_compute_instance" "target2" {
  name        = "target-node-2"
  platform_id = "standard-v2"
  zone = "ru-central1-d"
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.debian.image_id
      size     = 10
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_d.id
    nat       = true
  }
  metadata = {
    ssh-keys = "debian:${file("~/.ssh/terraform-yc.pub")}"
    user-data = local.cloud_init_target
  }
}

output "controller_ip" {
  value = yandex_compute_instance.controller.network_interface[0].nat_ip_address
}

output "target1_ip" {
  value = yandex_compute_instance.targeREMOVED_SECRET[0].nat_ip_address
}

output "target2_ip" {
  value = yandex_compute_instance.target2.network_interface[0].nat_ip_address
}