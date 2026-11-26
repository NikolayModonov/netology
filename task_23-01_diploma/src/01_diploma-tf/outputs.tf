output "node_public_ips" {
  value = {
    for name, vm in yandex_compute_instance.k8s_node :
    name => vm.network_interface[0].nat_ip_address
  }
}

output "node_private_ips" {
  value = {
    for name, vm in yandex_compute_instance.k8s_node :
    name => vm.network_interface[0].ip_address
  }
}

output "network_id" {
  value = yandex_vpc_network.diploma.id
}

output "subnet_ids" {
  value = {
    s1 = yandex_vpc_subnet.s1.id
    s2 = yandex_vpc_subnet.s2.id
    s3 = yandex_vpc_subnet.s3.id
  }
}