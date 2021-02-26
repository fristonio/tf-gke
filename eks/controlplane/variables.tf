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

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster."

  validation {
    condition     = length(var.cluster_name) > 5 && length(var.cluster_name) < 64
    error_message = "Length of the name of the cluster shoud be from 5 characters to 64 characters."
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

// One of vpc_clusters_subnets or subnets must be provided. If vpc_clusters_subents
// is provided, a cluster_index must also be provided. This cluster index will be used
// to select the subnet from the list in the vpc_clusters_subnets.
variable "cluster_index" {
  type        = number
  description = "Index of the cluster for getting subnet, if using multiple clusters within the same VPC."
  default     = 0

  validation {
    condition     = var.cluster_index >= 0 && var.cluster_index < 8
    error_message = "A maximum of 8 clusters can be created within this vpc, index must be in [0, 8)."
  }
}

variable "vpc_clusters_subnets" {
  type        = list(list(string))
  description = "A list of subnets in the VPC that can be used to create EKS clusters."
  default     = [[]]
}

variable "subnets" {
  type        = list(string)
  description = "A list of subnet IDs to associate with the EKS cluster."
  default     = []
}
