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
  source = "./modules/api/aws"

  environment       = var.environment
  lambda_invoke_arn = module.authorizer.lambda_function_invoke_arn
  lambda_name       = module.authorizer.lambda_function_name
  domain            = "jwnwilson.co.uk"
  api_subdomain     = "auth-${var.environment}" 
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

  attach_tracing_policy   = true
  tracing_mode            = "Active"

  # provisioned_concurrent_executions = 10
  # publish                 = true

  environment_variables = {
    ENVIRONMENT                 = var.environment
    SECRET                      = "d150fcaa-a124-42ae-9442-6b7388607a9e"
    # Move to param store     
    DB_URL                      = "postgresql+asyncpg://postgres:password@${module.db.db_instance_endpoint}/authorizer"
    GOOGLE_OAUTH_CLIENT_ID      = ""
    GOOGLE_OAUTH_CLIENT_SECRET  = ""
    EMAIL_ACCESS_TOKEN          = ""
    EMAIL_SERVICE_URL           = ""
  }

  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.security_group.security_group_id]
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
    SECRET                      = "d150fcaa-a124-42ae-9442-6b7388607a9e"
    # Move to param store     
    DB_URL                      = "postgresql+asyncpg://postgres:password@${module.db.db_instance_endpoint}/authorizer"
    GOOGLE_OAUTH_CLIENT_ID      = ""
    GOOGLE_OAUTH_CLIENT_SECRET  = ""
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
    SECRET                      = "d150fcaa-a124-42ae-9442-6b7388607a9e"
    # Move to param store     
    DB_URL                      = "postgresql+asyncpg://postgres:password@${module.db.db_instance_endpoint}/authorizer"
    GOOGLE_OAUTH_CLIENT_ID      = ""
    GOOGLE_OAUTH_CLIENT_SECRET  = ""
  }

  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.security_group.security_group_id]
}


################################################################################
# RDS Module
################################################################################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.project}-vpc-${var.environment}"
  cidr = "10.10.0.0/16"

  azs  = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  public_subnets  = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  private_subnets = ["10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24"]

  private_subnet_tags = {
    Tier = "Private"
  }
  public_subnet_tags = {
    Tier = "Public"
  }

  tags = {
    project = var.project
    Environment = var.environment
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name        = "${var.project}-sg-${var.environment}"
  description = "Complete PostgreSQL example security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = "${var.project}-db-${var.environment}"

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "11.13"
  family               = "postgres11" # DB parameter group
  major_engine_version = "11"         # DB option group
  instance_class       = "db.t2.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = false

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  name     = "authorizer"
  username = "postgres"
  password = "password"
  port     = 5432

  multi_az               = false
  subnet_ids             = module.vpc.private_subnets
  vpc_security_group_ids = [module.security_group.security_group_id]

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]
}
