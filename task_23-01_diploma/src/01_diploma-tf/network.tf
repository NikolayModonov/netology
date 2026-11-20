resource "yandex_vpc_network" "diploma" {
  name = "diploma-net"
}

resource "yandex_vpc_subnet" "a" {
  name           = "diploma-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.diploma.id
  v4_cidr_blocks = ["10.10.1.0/24"]
}

resource "yandex_vpc_subnet" "b" {
  name           = "diploma-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.diploma.id
  v4_cidr_blocks = ["10.10.2.0/24"]
}

resource "yandex_vpc_subnet" "d" {
  name           = "diploma-subnet-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.diploma.id
  v4_cidr_blocks = ["10.10.3.0/24"]
}