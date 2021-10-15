terraform {
  required_providers {
    yandex = {
      version = "0.35"
    }
  }
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

resource "yandex_storage_bucket" "terr-state-bckt" {
  access_key = var.access_key
  secret_key = var.secret_key
  bucket     = "terr-state-bckt"
}
