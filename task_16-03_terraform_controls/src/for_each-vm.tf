resource "yandex_compute_instance" "db" {
  for_each    = { for vm in var.each_vm : vm.vm_name => vm }
  name        = each.value.vm_name
  platform_id = var.vm_platform_id
  zone        = local.subnets[each.value.subnet_name] == yandex_vpc_subnet.develop.id ? "ru-central1-a" : "ru-central1-d"
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
    subnet_id          = local.subnets[each.value.subnet_name]
    nat                = var.vm_nat
    security_group_ids = [yandex_vpc_security_group.example.id]
  }
  metadata = local.metadata
}