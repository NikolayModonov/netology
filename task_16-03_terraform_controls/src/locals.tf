locals {
  ssh_key = file("~/.ssh/terraform-yc.pub")
  metadata = {
    serial-port-enable = "1"
    ssh-keys           = "ubuntu:${local.ssh_key}"
  }
  subnets = {
    "develop"   = yandex_vpc_subnet.develop.id
    "develop_d" = yandex_vpc_subnet.develop_d.id
  }
}