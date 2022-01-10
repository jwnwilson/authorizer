terraform {
  backend "s3" {
    region = "eu-west-1"
    bucket = "jwnwilson-authorizer"
    key = "terraform.tfstate"
  }
}

provider "aws" {
  region  = var.aws_region
}

module "authorizer" {
  source                  = "terraform-aws-modules/lambda/aws"

  function_name           = "authorizer_${var.environment}"
  description             = "Authorizer API"

  create_package          = false

  image_uri               = "${var.ecr_api_url}:${var.docker_tag}"
  package_type            = "Image"
  attach_network_policy   = true
  timeout                 = 30

  environment_variables = {
    ENVIRONMENT = var.environment
  }

}
