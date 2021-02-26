variable "aws_region" {
  type        = string
  description = "AWS region to use with the terraform module."
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
    condition     = length(var.vpc_name) > 5 && length(var.vpc_name) < 64
    error_message = "Length of the name of the VPC shoud be from 5 characters to 64 characters."
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

variable "tags" {
  default     = {}
  description = "Additional tags to associate with the resources."
  type        = map(string)
}
