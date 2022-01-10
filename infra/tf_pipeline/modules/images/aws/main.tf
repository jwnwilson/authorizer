variable "api_repo" {}

variable "access_key" {}

variable "secret_key" {}

variable "region" {}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_ecr_repository" "api_repo" {
  name                 = var.api_repo
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
