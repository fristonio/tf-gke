variable "project_id" {
  type        = string
  description = "GCP project to create the Kubernetes cluster in"
}

variable "vpc_name" {
  type        = string
  description = "VPC to create the cluster in."

  validation {
    condition     = length(var.vpc_name) > 5 && length(var.vpc_name) < 64
    error_message = "Length of the name of the vpc shoud be from 6 characters to 64 characters."
  }
}

variable "cluster_location" {
  type        = string
  description = "Location to create the GKE clsuter in."
}

variable "cluster_name" {
  type        = string
  description = "Name of the GKE cluster."

  validation {
    condition     = length(var.cluster_name) > 5 && length(var.cluster_name) < 64
    error_message = "Length of the name of the cluster shoud be from 6 characters to 64 characters."
  }
}

variable "kubernetes_version" {
  type        = string
  default     = "latest"
  description = "Kubernetes version to use for the GKE cluster."
}
