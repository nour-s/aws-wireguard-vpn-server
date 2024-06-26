data "aws_availability_zones" "available" {}

module "vpc_main" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "wireguard"
  cidr                 = var.vpc_cidr
  public_subnets       = var.vpc_public_subnets
  azs                  = data.aws_availability_zones.available.names
  enable_dns_hostnames = true

  tags = {
    Name = "wireguard"
  }
}


resource "aws_key_pair" "wireguard" {
  key_name   = "wireguard"
  public_key = file(var.gateway_ssh_public_key)
}

resource "aws_instance" "wireguard" {
  ami                    = data.aws_ami.ubuntu.id
  subnet_id              = module.vpc_main.public_subnets[0]
  instance_type          = var.gateway_instance_type
  key_name               = aws_key_pair.wireguard.key_name
  vpc_security_group_ids = [aws_security_group.wireguard.id]

  root_block_device {
    volume_size = var.gateway_instance_disk_size
  }

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name : "wireguard"
  }
}

resource "aws_eip" "wireguard" {
  instance = aws_instance.wireguard.id

  tags = {
    Name : "wireguard"
  }
}

resource "aws_security_group" "wireguard" {
  name   = "wireguard"
  vpc_id = module.vpc_main.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [var.gateway_network]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.gateway_network]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name : "wireguard"
  }
}

# Create the SES email identity
resource "aws_ses_email_identity" "email_to_receive_keys" {
  email = var.email_address
}

data "aws_iam_policy_document" "email_policy_doc" {
  statement {
    actions   = ["SES:SendEmail", "SES:SendRawEmail"]
    resources = [aws_ses_email_identity.email_to_receive_keys.arn]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}


resource "aws_ses_identity_policy" "email_policy" {
  name     = "email_identity_policy"
  identity = aws_ses_email_identity.email_to_receive_keys.email
  policy   = data.aws_iam_policy_document.email_policy_doc.json
}
