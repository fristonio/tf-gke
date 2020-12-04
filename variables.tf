variable "subnets" {
  type    = map(string)
  # this is based on default network's config
  default = {
    us-central1	             = "10.128.0.0/20"
    us-east1                 = "10.142.0.0/20"
  }
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
    condition     = contains(["us-central1", "us-east1"], var.cluster_location)
    error_message = "Cluster location must be from a predefined list for which we have subnets defined."
  }
}

variable "node_machine_type" {
  type        = string
  description = "GCP machine type to use for the Kubernetes cluster node"

  validation {
    condition     = contains(["n1-standard-4", "n2-standard-2"], var.node_machine_type)
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
  type        = string
  default     = "1"
  description = "Number of worker nodes in the Kubernetes cluster."

  validation {
    condition     = can(tonumber(var.node_count)) && tonumber(var.node_count) > 0 && tonumber(var.node_count) < 5
    error_message = "Node count for the cluster must be between 0-5."
  }
}

variable "project_id" {
  type        = string
  description = "GCP project to create the Kuberentes cluster in"
}

variable "svc_account_key" {
  type        = string
  description = "Service account key in Base64 encoded format."

  validation {
      condition   = can(base64decode(var.svc_account_key))
      description = "The service account key is not in base64 encoded format."
  }
}
