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
  name = "k8s-net"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "k8s-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.0.8.0/24"]
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "vm" {
  name        = "k8s-vm"
  platform_id = "standard-v2"
  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = 20
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }
  metadata = {
    ssh-keys = "ubuntu:${file(pathexpand("~/.ssh/terraform-yc.pub"))}"
    user-data = <<-EOF
#cloud-config
package_update: true
packages:
  - snapd
runcmd:
  - snap install microk8s --classic --channel=1.28
  - usermod -a -G microk8s ubuntu
  - microk8s enable dns
  - microk8s enable hostpath-storage
  - mkdir -p /home/ubuntu/.kube
  - microk8s config > /home/ubuntu/.kube/config
  - chown -R ubuntu:ubuntu /home/ubuntu/.kube
  - sleep 20
  - microk8s kubectl get nodes > /tmp/k8s-ready.txt
EOF
  }
}

output "vm_ip" {
  value = yandex_compute_instance.vm.network_interface[0].nat_ip_address
}