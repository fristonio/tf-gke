variable "project_id" {
  type        = string
  description = "GCP project to create the Kubernetes cluster in"
}

variable "svc_account_key" {
  type        = string
  description = "Service account key in Base64 encoded format."

  validation {
      condition   = can(base64decode(var.svc_account_key))
      error_message = "The service account key is not in base64 encoded format."
  }
}

variable "region" {
  type        = string
  description = "GCP region to use with the provider."
}

variable "vpc_name" {
  type        = string
  description = "VPC to create the GKE cluster in."

  validation {
    condition     = length(var.vpc_name) > 5 && length(var.vpc_name) < 64
    error_message = "Length of the name of the vpc shoud be from 6 characters to 64 characters."
  }
}
