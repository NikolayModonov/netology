resource "yandex_vpc_network" "diploma" {
  name = "diploma-net"
}

resource "yandex_vpc_subnet" "s1" {
  name           = "diploma-subnet-1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.diploma.id
  v4_cidr_blocks = ["10.10.1.0/24"]
}

resource "yandex_vpc_subnet" "s2" {
  name           = "diploma-subnet-2"
  zone           = "ru-central1-e"
  network_id     = yandex_vpc_network.diploma.id
  v4_cidr_blocks = ["10.10.2.0/24"]
}

resource "yandex_vpc_subnet" "s3" {
  name           = "diploma-subnet-3"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.diploma.id
  v4_cidr_blocks = ["10.10.3.0/24"]
}