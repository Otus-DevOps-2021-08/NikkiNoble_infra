terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "terr-state-bckt"
    region     = "us-east-1"
    key        = "stage/terraform.tfstate"
    access_key = "I9wqmfK8EQL0tCM--fox"
    secret_key = "IiqXyuZGSvn-DhpkCz3stestyiHhwFVtestHG4-b"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
