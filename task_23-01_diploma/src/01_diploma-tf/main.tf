terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.120.0"
    }
  }

  backend "s3" {
    bucket                      = "nikolay-modonov-diploma-tf-state"
    key                         = "diploma.tfstate"
    region                      = "ru-central1"
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    use_lockfile                = true
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "yandex" {}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}