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

module "api_gateway" {
  source = "github.com/jwnwilson/terraform-aws-modules/modules/apigateway-authorizer"

  environment       = var.environment
  lambda_invoke_arn = module.authorizer.lambda_function_invoke_arn
  lambda_name       = module.authorizer.lambda_function_name
  domain            = "jwnwilson.co.uk"
  api_subdomain     = "auth-${var.environment}"
  project           = "authorizer"
}

# This need to be created manually
data "aws_ssm_parameter" "access_token" {
  name = "/authorizer/${var.environment}/access_token"
}

# This need to be created manually
data "aws_ssm_parameter" "email_url" {
  name = "/authorizer/${var.environment}/email_url"
}

# This need to be created manually
data "aws_ssm_parameter" "secret" {
  name = "/authorizer/${var.environment}/secret"
}

# This need to be created manually
data "aws_ssm_parameter" "username" {
  name = "/authorizer/${var.environment}/username"
}

# This need to be created manually
data "aws_ssm_parameter" "password" {
  name = "/authorizer/${var.environment}/password"
}

# This need to be created manually
data "aws_ssm_parameter" "service_token_user" {
  name = "/authorizer/${var.environment}/service_token_user"
}

module "authorizer" {
  source                  = "terraform-aws-modules/lambda/aws"

  function_name           = "authorizer_${var.environment}"
  description             = "Authorizer API"

  create_package          = false

  image_uri               = "${var.ecr_api_url}:${var.docker_tag}"
  package_type            = "Image"
  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.security_group.security_group_id]
  attach_network_policy   = true
  timeout                 = 30

  attach_tracing_policy   = true
  tracing_mode            = "Active"

  # provisioned_concurrent_executions = 10
  # publish                 = true

  environment_variables = {
    ENVIRONMENT                 = var.environment
    SECRET                      = data.aws_ssm_parameter.access_token.value
    DB_URL                      = "postgresql+asyncpg://postgres:password@${module.db.db_instance_endpoint}/authorizer"
    GOOGLE_OAUTH_CLIENT_ID      = ""
    GOOGLE_OAUTH_CLIENT_SECRET  = ""
    EMAIL_ACCESS_TOKEN          = data.aws_ssm_parameter.access_token.value
    EMAIL_SERVICE_URL           = data.aws_ssm_parameter.email_url.value
  }
}

resource "aws_cloudwatch_event_rule" "every_one_minute" {
  name                = "every-one-minute"
  description         = "Fires every one minutes"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "check_foo_every_one_minute" {
  rule      = "${aws_cloudwatch_event_rule.every_one_minute.name}"
  target_id = "lambda"
  arn       = "${module.authorizer.lambda_function_arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${module.authorizer.lambda_function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.every_one_minute.arn}"
}

module "authorizer_api_gw" {
  source                  = "terraform-aws-modules/lambda/aws"

  function_name           = "authorizer_api_gw_${var.environment}"
  description             = "Authorizer for API GW"

  create_package          = false

  image_uri               = "${var.ecr_api_url}:${var.docker_tag}"
  image_config_command    = ["app.adapter.into.lambda.authorizer.lambda_handler"]
  package_type            = "Image"
  attach_network_policy   = true
  timeout                 = 30

  environment_variables = {
    ENVIRONMENT                 = var.environment
    SECRET                      = data.aws_ssm_parameter.access_token.value
    DB_URL                      = "postgresql+asyncpg://postgres:password@${module.db.db_instance_endpoint}/authorizer"
    GOOGLE_OAUTH_CLIENT_ID      = ""
    GOOGLE_OAUTH_CLIENT_SECRET  = ""
    EMAIL_ACCESS_TOKEN          = data.aws_ssm_parameter.access_token.value
    EMAIL_SERVICE_URL           = data.aws_ssm_parameter.email_url.value
  }

  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.security_group.security_group_id]
}

module "db_migrator" {
  source                  = "terraform-aws-modules/lambda/aws"

  function_name           = "authorizer_db_migrate_${var.environment}"
  description             = "Authorizer DB migration command"

  create_package          = false

  image_uri               = "${var.ecr_api_url}:${var.docker_tag}"
  image_config_command    = ["app.adapter.into.lambda.db_command.lambda_handler"]
  package_type            = "Image"
  attach_network_policy   = true
  timeout                 = 900

  environment_variables = {
    ENVIRONMENT                 = var.environment
    SECRET                      = data.aws_ssm_parameter.access_token.value
    DB_URL                      = "postgresql+asyncpg://postgres:password@${module.db.db_instance_endpoint}/authorizer"
    GOOGLE_OAUTH_CLIENT_ID      = ""
    GOOGLE_OAUTH_CLIENT_SECRET  = ""
    EMAIL_ACCESS_TOKEN          = data.aws_ssm_parameter.access_token.value
    EMAIL_SERVICE_URL           = data.aws_ssm_parameter.email_url.value
  }

  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.security_group.security_group_id]
}

module "service_token_generator" {
  source                  = "terraform-aws-modules/lambda/aws"

  function_name           = "authorizer_service_token_gen_${var.environment}"
  description             = "Authorizer for service token gen"

  create_package          = false

  image_uri               = "${var.ecr_api_url}:${var.docker_tag}"
  image_config_command    = ["app.adapter.into.lambda.service_token.lambda_handler"]
  package_type            = "Image"
  attach_network_policy   = true
  timeout                 = 30

  environment_variables = {
    ENVIRONMENT                 = var.environment
    SECRET                      = data.aws_ssm_parameter.access_token.value
    DB_URL                      = "postgresql+asyncpg://postgres:password@${module.db.db_instance_endpoint}/authorizer"
    GOOGLE_OAUTH_CLIENT_ID      = ""
    GOOGLE_OAUTH_CLIENT_SECRET  = ""
    EMAIL_ACCESS_TOKEN          = data.aws_ssm_parameter.access_token.value
    EMAIL_SERVICE_URL           = data.aws_ssm_parameter.email_url.value
    SERVICE_TOKEN_USER          = data.aws_ssm_parameter.service_token_user.value
  }

  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.security_group.security_group_id]
}
