resource "local_file" "hosts" {
  content = templatefile("${path.module}/hosts.tftpl", {
    webservers = [
      for vm in yandex_compute_instance.web : {
        name   = vm.name
        nat_ip = vm.network_interface[0].nat_ip_address
        fqdn   = vm.fqdn
      }
    ]
    databases = [
      for vm in yandex_compute_instance.db : {
        name   = vm.name
        nat_ip = vm.network_interface[0].nat_ip_address
        fqdn   = vm.fqdn
      }
    ]
    storage = [
      {
        name   = yandex_compute_instance.storage.name
        nat_ip = yandex_compute_instance.storage.network_interface[0].nat_ip_address
        fqdn   = yandex_compute_instance.storage.fqdn
      }
    ]
  })
  filename = "${path.module}/hosts.ini"
}