resource "yandex_compute_instance" "db" {
  for_each    = { for vm in var.each_vm : vm.vm_name => vm }
  name        = each.value.vm_name
  platform_id = var.vm_platform_id
  zone        = each.value.zone
  resources {
    cores         = each.value.cpu
    memory        = each.value.ram
    core_fraction = var.vm_core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = each.value.disk_volume
    }
  }
  scheduling_policy {
    preemptible = var.vm_preemptible
  }
  network_interface {
    subnet_id = each.value.zone == "ru-central1-a" ? yandex_vpc_subnet.develop.id : yandex_vpc_subnet.develop_d.id
    nat       = true
  }
  metadata = local.metadata
}