
## Bastion access to vpc
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_iam_policy_document" "assume" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com",
        "ssm.amazonaws.com",
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ssm_role" {
  name               = "${var.project}-ssm-terraform"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}


resource "aws_iam_instance_profile" "bastion" {
  name = "ssm-poc-instance-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_standard" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::675468650888:role/authorizer-ssm-terraform"
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.image_id
  iam_instance_profile        = aws_iam_instance_profile.bastion.name
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [module.security_group.security_group_id]
  associate_public_ip_address = false
  #key_name                    = aws_key_pair.ssm_key.key_name
  #monitoring                  = true
  #ebs_optimized               = true
  subnet_id                   = module.vpc.private_subnets[0]

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_tokens = "required"
    http_endpoint = "enabled"
  }
}
