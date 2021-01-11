terraform {
  required_version = ">= 0.14.0"

  required_providers {
    aws = {
      version = ">= 3.21.0"
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
