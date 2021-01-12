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
    condition     = contains(["1.17", "1.16", "1.15"], var.kubernetes_version)
    error_message = "Kubernetes version provided is not supported."
  }
}

variable "subnets" {
  type        = list(string)
  description = "A list of subnet IDs to associate with the EKS cluster."

  validation {
    condition     = length(var.subnets) > 0
    error_message = "Atleast one subnet must be specified for the cluster."
  }
}

variable "desired_size" {
  type        = number
  description = "Desired size of the EKS cluster node pool."

  validation {
    condition     = var.desired_size < 5 && var.desired_size > 0
    error_message = "Desired size of the nodegroup should be between (0, 5)."
  }
}

variable "max_size" {
  type        = number
  description = "Maximum size of the EKS cluster node group."

  validation {
    condition     = var.max_size < 5 && var.max_size > 0
    error_message = "Max size of the nodegroup should be between (0, 5)."
  }
}

variable "min_size" {
  type        = number
  description = "Minimum size of the EKS cluster node group."

  validation {
    condition     = var.min_size < 5 && var.min_size > 0
    error_message = "Min size of the nodegroup should be between (0, 5)."
  }
}

variable "disk_size" {
  type        = number
  description = "Disk size for each node in the EKS cluster node group."

  validation {
    condition     = var.disk_size > 20 && var.disk_size < 100
    error_message = "Disk size for the nodes should be between (20 GiB, 100GiB)."
  }
}

variable "ami_type" {
  type        = string
  description = "AMI type to use for the nodegroup."
  default     = "AL2_x86_64"

  validation {
    condition     = contains(["AL2_x86_64"], var.ami_type)
    error_message = "AMI type for the node should be from a predefined list of ami types."
  }
}

variable "instance_type" {
  type        = string
  description = "Instance type to use for instance in the nodegroup."

  validation {
    condition     = contains(["t3.medium", "t3.small", "t2.medium", "t2.large", "t3.large"], var.instance_type)
    error_message = "Instance type for the node should be from a predefined list of instance types."
  }
}
