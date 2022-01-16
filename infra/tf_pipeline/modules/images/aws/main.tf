variable "auth_repo" {}

variable "access_key" {}

variable "secret_key" {}

variable "region" {}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_ecr_repository" "auth_repo" {
  name                 = var.auth_repo
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
