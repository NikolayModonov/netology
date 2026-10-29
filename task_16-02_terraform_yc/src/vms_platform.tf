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

variable "vm_db_platform_id" {
  type    = string
  default = "standard-v2"
}

# ###web resources
#
# variable "vm_web_cores" {
#   type    = number
#   default = 2
# }
#
# variable "vm_web_memory" {
#   type    = number
#   default = 1
# }
#
# variable "vm_web_core_fraction" {
#   type    = number
#   default = 5
# }
#
# variable "vm_web_preemptible" {
#   type    = bool
#   default = true
# }
#
# ###db resources
#
# variable "vm_db_cores" {
#   type    = number
#   default = 2
# }
#
# variable "vm_db_memory" {
#   type    = number
#   default = 2
# }
#
# variable "vm_db_core_fraction" {
#   type    = number
#   default = 20
# }
#
# variable "vm_db_preemptible" {
#   type    = bool
#   default = true
# }

###maps

variable "vms_resources" {
  type = map(object({
    cores         = number
    memory        = number
    core_fraction = number
    hdd_size      = number
    hdd_type      = string
    preemptible   = bool
  }))
  default = {
    web = {
      cores         = 2
      memory        = 1
      core_fraction = 5
      hdd_size      = 5
      hdd_type      = "network-hdd"
      preemptible   = true
    }
    db = {
      cores         = 2
      memory        = 2
      core_fraction = 20
      hdd_size      = 5
      hdd_type      = "network-hdd"
      preemptible   = true
    }
  }
}

###metadata

variable "metadata" {
  type = map(string)
}