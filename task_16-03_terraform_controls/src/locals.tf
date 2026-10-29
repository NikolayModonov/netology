locals {
  ssh_key  = file("~/.ssh/terraform-yc.pub")
  metadata = {
    serial-port-enable = "1"
    ssh-keys           = "ubuntu:${local.ssh_key}"
  }
}