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

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster."

  validation {
    condition     = length(var.cluster_name) > 6 && length(var.cluster_name) < 32
    error_message = "Length of the name of the cluster shoud be from 6 characters to 32 characters."
  }
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version to use for the EKS cluster."

  validation {
    condition     = contains(["1.17", "1.16", "1.15", "latest"], var.kubernetes_version)
    error_message = "Kubernetes version provided is not supported."
  }
}

variable "subnets" {
  type        = list(string)
  description = "A list of subnet IDs to associate with the EKS cluster."
  default     = []
}

variable "vpc_subnets" {
  type        = list(list(string))
  description = "A list of cluster subnets IDs for a pool of EKS cluster."
  default     = [[]]
}

variable "cluster_index" {
  type        = number
  description = "Index in the vpc_subnets list to use as cluster subnet."
  default     = 0
}
