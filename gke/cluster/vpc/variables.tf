variable "vpc_name" {
  type        = string
  description = "VPC to create the cluster in."

  validation {
    condition     = length(var.vpc_name) > 5 && length(var.vpc_name) < 64
    error_message = "Length of the name of the vpc shoud be from 6 characters to 64 characters."
  }
}