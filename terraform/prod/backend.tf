terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "terr-state-bckt"
    region     = "us-east-1"
    key        = "prod/terraform.tfstate"
    # to pass access/secret keys use command:
    # terraform init -backend-config="access_key=xxx" -backend-config="secret_key=xxx"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
