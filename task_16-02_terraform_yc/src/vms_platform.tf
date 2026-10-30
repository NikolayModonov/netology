###project

variable "vm_project" {
  type    = string
  default = "netology"
}

###web vm

variable "vm_web_platform_id" {
  type    = string
  default = "standard-v2"
}

###web image

variable "vm_web_image_family" {
  type    = string
  default = "ubuntu-2004-lts"
}

###db vm

variable "vm_db_name" {
  type    = string
  default = "netology-develop-platform-db"
}

variable "vm_db_platform_id" {
  type    = string
  default = "standard-v2"
}

variable "vm_db_zone" {
  type    = string
  default = "ru-central1-d"
}

###db subnet

variable "vm_db_subnet_cidr" {
  type    = list(string)
  default = ["10.0.2.0/24"]
}

###maps

variable "vms_resources" {
  type = map(object({
    cores         = number
    memory        = number
    core_fraction = number
    hdd_size      = number
    hdd_type      = string
    preemptible   = bool
    nat           = bool
  }))
  default = {
    web = {
      cores         = 2
      memory        = 1
      core_fraction = 5
      hdd_size      = 5
      hdd_type      = "network-hdd"
      preemptible   = true
      nat           = true
    }
    db = {
      cores         = 2
      memory        = 2
      core_fraction = 20
      hdd_size      = 5
      hdd_type      = "network-hdd"
      preemptible   = true
      nat           = true
    }
  }
}

###metadata

variable "metadata" {
  type = map(string)
}