locals {
  k8s_nodes = {
    node-1 = { zone = "ru-central1-a", subnet_id = yandex_vpc_subnet.s1.id }
    node-2 = { zone = "ru-central1-e", subnet_id = yandex_vpc_subnet.s2.id }
    node-3 = { zone = "ru-central1-d", subnet_id = yandex_vpc_subnet.s3.id }
  }
}

resource "yandex_compute_instance" "k8s_node" {
  for_each = local.k8s_nodes

  name        = each.key
  platform_id = "standard-v2"
  zone        = each.value.zone

  resources {
    cores         = 4
    memory        = 8
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = 50
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id = each.value.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(pathexpand(var.ssh_public_key_path))}"
  }
}