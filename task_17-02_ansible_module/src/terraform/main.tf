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
  name = "module-test-net"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "module-test-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.0.3.0/24"]
}

data "yandex_compute_image" "debian" {
  family = "debian-12"
}

resource "yandex_compute_instance" "vm" {
  name        = "ansible-module-vm"
  platform_id = "standard-v2"
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.debian.image_id
      size     = 5
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }
  metadata = {
    ssh-keys = "debian:${file(pathexpand("~/.ssh/terraform-yc.pub"))}"
  }
}

output "vm_ip" {
  value = yandex_compute_instance.vm.network_interface[0].nat_ip_address
}