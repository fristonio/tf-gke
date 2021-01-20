variable "vpc_name" {
  type        = string
  description = "VPC to create the cluster in."

  validation {
    condition     = length(var.vpc_name) > 6 && length(var.vpc_name) < 32
    error_message = "Length of the name of the vpc shoud be from 6 characters to 32 characters."
  }
}