variable "aws_region" {
  type        = string
  description = "AWS region to use with the terraform module."

  validation {
    condition     = contains(["us-west-2", "us-east-2"], var.aws_region)
    error_message = "AWS region must be from a predefined list for which we have subnets defined."
  }
}

variable "aws_access_key" {
  type        = string
  description = "AWS access key to use with the terraform module."
  sensitive   = true
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key to use with the terraform module."
  sensitive   = true
}

variable "vpc_name" {
  type        = string
  description = "Name of the vpc to create."

  validation {
    condition     = length(var.vpc_name) > 6 && length(var.vpc_name) < 32
    error_message = "Length of the name of the VPC shoud be from 6 characters to 32 characters."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR to use for the VPC."
  default     = "10.0.0.0/16"

  validation {
    condition     = length([ for cidr_block in cidrsubnets(var.vpc_cidr, 6, 6, 6, 6, 6, 6, 6, 6, 6) : cidrsubnets(cidr_block, 2, 2, 2) ]) == 9

    error_message = "CIDR must be a valid cidr, for example 10.0.0.0/16."
  }
}
