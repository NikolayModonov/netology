terraform {
  required_version = ">= 1.6.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.120"
    }
  }

  backend "s3" {
    bucket                      = "nikolay-modonov-diploma-tf-state"
    key                         = "diploma/terraform.tfstate"
    region                      = "ru-central1"
    endpoints                   = {
      s3 = "https://storage.yandexcloud.net"
    }
    force_path_style            = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
  }
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.default_zone
  service_account_key_file = pathexpand(var.sa_key_file)
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}