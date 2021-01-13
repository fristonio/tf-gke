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
