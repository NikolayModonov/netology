###cloud vars

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "subnet_d_zone" {
  type    = string
  default = "ru-central1-d"
}

variable "subnet_d_cidr" {
  type    = list(string)
  default = ["10.0.2.0/24"]
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

###vm common

variable "vm_image_family" {
  type    = string
  default = "ubuntu-2004-lts"
}

variable "vm_platform_id" {
  type    = string
  default = "standard-v2"
}

variable "vm_cores" {
  type    = number
  default = 2
}

variable "vm_memory" {
  type    = number
  default = 1
}

variable "vm_core_fraction" {
  type    = number
  default = 5
}

variable "vm_preemptible" {
  type    = bool
  default = true
}

variable "vm_nat" {
  type    = bool
  default = true
}

variable "vm_disk_size" {
  type    = number
  default = 5
}

###disk vars

variable "disk_extra_size" {
  type    = number
  default = 1
}

variable "disk_extra_type" {
  type    = string
  default = "network-hdd"
}

variable "disk_extra_zone" {
  type    = string
  default = "ru-central1-d"
}

variable "vm_storage_zone" {
  type    = string
  default = "ru-central1-d"
}

variable "vm_storage_disk_size" {
  type    = number
  default = 5
}

variable "vm_storage_disk_type" {
  type    = string
  default = "network-hdd"
}

###db vms

variable "each_vm" {
  type = list(object({
    vm_name     = string
    cpu         = number
    ram         = number
    disk_volume = number
    subnet_name = string
  }))
}