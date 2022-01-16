/* general */
variable "environment" {
  default = "develop"
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "region" {
  default = "eu-west-1"
}

variable "aws_access_key" {
}

variable "aws_secret_key" {
}

variable "project" {
  default = "authorizer"
}

variable "ecr_api_url" {}

variable "auth_repo" {
  description = "Name of container image repository"
  default     = "authorizer"
}