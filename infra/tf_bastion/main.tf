terraform {
  backend "s3" {
    region = "eu-west-1"
    bucket = "jwnwilson-authorizer"
    key = "terraform-bastion.tfstate"
  }
}

provider "aws" {
  region  = var.aws_region
}

data "aws_ami" "amazon-2" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners = ["amazon"]
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnet_ids" "vpc_subnets" {
  vpc_id = var.vpc_id

  tags = {
    Tier = "Public"
  }
}

data "aws_security_group" "selected" {
  vpc_id = var.vpc_id

  filter {
    name   = "group-name"
    values = ["default"]
  }
}

# Setup EC2 instance using ubuntu AMI
resource "aws_instance" "ssm_instance" {
  ami                           = data.aws_ami.amazon-2.id
  instance_type                 = "t2.micro"
  associate_public_ip_address   = true
  iam_instance_profile          = aws_iam_instance_profile.ssm_profile.name
  vpc_security_group_ids        = [data.aws_security_group.selected.id]
  subnet_id                     = tolist(data.aws_subnet_ids.vpc_subnets.ids)[0]
  user_data = file("./bastion_init.sh")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "ssm" # Please change name tag here
  }
}

# Configure IAM instance profile
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm-profile"
  role = "AmazonSSMRoleForInstancesQuickSetup"
}