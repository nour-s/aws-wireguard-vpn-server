terraform {
  required_version = "~> 1.0"
  backend "s3" {
    key    = "terraform"
  }

  required_providers {
    aws = {
      version = "> 3.0"
    }
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}
