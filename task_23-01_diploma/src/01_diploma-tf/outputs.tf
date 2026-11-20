output "k8s_nodes" {
  value = {
    for k, v in yandex_compute_instance.k8s_node : k => {
      name        = v.name
      zone        = v.zone
      external_ip = v.network_interface[0].nat_ip_address
      internal_ip = v.network_interface[0].ip_address
    }
  }
}

output "vpc_network_id" {
  value = yandex_vpc_network.diploma.id
}

output "subnet_ids" {
  value = {
    a = yandex_vpc_subnet.a.id
    b = yandex_vpc_subnet.b.id
    d = yandex_vpc_subnet.d.id
  }
}