variable "subnet_cidr" {
  type        = string
  default     = "10.128.0.0/20"
  description = "Subnet CIDR to create for the location in the VPC."
}

variable "cluster_name" {
  type        = string
  description = "Name of the GKE cluster."

  validation {
    condition     = length(var.cluster_name) > 6 && length(var.cluster_name) < 32
    error_message = "Length of the name of the cluster shoud be from 6 characters to 32 characters."
  }
}

variable "cluster_location" {
  type        = string
  description = "Location to create the GKE clsuter in."

  validation {
    condition     = contains(["us-central1", "us-east1", "us-west1"], var.cluster_location)
    error_message = "Cluster location must be from a predefined list for which we have subnets defined."
  }
}

variable "node_zones" {
  type    = list(string)
  description = "A list of zones in the location provided in which to launch the nodes."

  validation {
    condition     = length(var.node_zones) < 4 && length(var.node_zones) > 0
    error_message = "The number of availability zones must be between [0, 3]."
  }
}

variable "node_machine_type" {
  type        = string
  description = "GCP machine type to use for the Kubernetes cluster node"

  validation {
    condition     = contains(["n1-standard-8", "n1-standard-4", "n1-standard-2", "n1-standard-1"], var.node_machine_type)
    error_message = "Node machine type for the cluster must be from the predefined list."
  }
}

variable "node_image_type" {
  type        = string
  description = "Image to use for the Kubernetes node"

  validation {
    condition     = contains(["COS_CONTAINERD"], var.node_image_type)
    error_message = "Node image type to use for the Kubernetes node."
  }
}

variable "node_count" {
  type        = number
  default     = 1
  description = "Number of worker nodes in the Kubernetes cluster."

  validation {
    condition     = var.node_count > 0 && var.node_count < 100
    error_message = "Node count for the cluster must be between 0-100."
  }
}

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

variable "kubernetes_version" {
  type        = string
  default     = "latest"
  description = "Kubernetes version to use for the GKE cluster."
}
