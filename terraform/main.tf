module "vpc_main" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "wireguard"
  cidr                 = var.vpc_cidr
  public_subnets       = var.vpc_public_subnets
  azs                  = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  enable_dns_hostnames = true

  tags = {
    Name : "wireguard"
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
  email = "var.email_address"
}

resource "aws_ses_identity_policy" "email_policy" {
  identity = "aws_ses_email_identity.email_to_receive_keys.email"

  policy =
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "ses:SendEmail",
        "Resource": "*"
      }
    ]
  }
}

# Create a local-exec provisioner that sends an email using SES
resource "null_resource" "send_email" {
  provisioner "local-exec" {
    command = <<EOF
      # Use the AWS CLI to send an email using the verified SES email identity
      aws ses send-email \
        --from "${aws_ses_email_identity.email_to_receive_keys.email}" \
        --to "${aws_ses_email_identity.email_to_receive_keys.email}" \
        --subject "AWS Wireguard Keys" \
        --text "Here are the keys to your wireguard"
    EOF
  }
}