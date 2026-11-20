locals {
  k8s_zones = {
    node-a = { zone = "ru-central1-a", subnet_id = yandex_vpc_subnet.a.id }
    node-b = { zone = "ru-central1-b", subnet_id = yandex_vpc_subnet.b.id }
    node-d = { zone = "ru-central1-d", subnet_id = yandex_vpc_subnet.d.id }
  }
}

resource "yandex_compute_instance" "k8s_node" {
  for_each = local.k8s_zones

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