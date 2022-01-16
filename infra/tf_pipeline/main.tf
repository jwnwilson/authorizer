terraform {
  backend "s3" {
    region = "eu-west-1"
    bucket = "jwnwilson-authorizer"
    key = "terraform-pipeline.tfstate"
  }
}

provider "aws" {
  region  = var.aws_region
}

module "docker_images" {
  source = "./modules/images/aws"

  auth_repo        = var.auth_repo
  access_key      = var.aws_access_key
  secret_key      = var.aws_secret_key
  region          = var.aws_region
}
