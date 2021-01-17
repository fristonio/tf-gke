variable "project_id" {
  type        = string
  description = "GCP project to create the Kubernetes cluster in."
}

variable "svc_account_key" {
  type        = string
  description = "Service account key in Base64 encoded format."

  validation {
      condition   = can(base64decode(var.svc_account_key))
      error_message = "The service account key is not in base64 encoded format."
  }
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC for the k8s cluster."

  validation {
    condition     = length(var.vpc_name) > 5 && length(var.vpc_name) < 32
    error_message = "Length of the name of the cluster shoud be from 6 characters to 32 characters."
  }
}

variable "vpc_configured" {
  type        = bool
  default     = false
  description = "If the VPC is already configured or not."
}

variable "cluster_name" {
  type        = string
  description = "Name of the Kubernetes cluster."

  validation {
    condition     = length(var.cluster_name) > 5 && length(var.cluster_name) < 32
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

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version to use for the GKE cluster."
}

variable "cluster_cidr" {
  type        = string
  description = "CIDR to use for the Kubernetes cluster."

  validation {
    condition     = can(cidrnetmask(var.cluster_cidr))
    error_message = "Cluster CIDR must be a valid network CIDR."
  }
}

variable "controlplane_nodes_count" {
  type        = number
  default     = 1
  description = "Number of controlplane nodes in the Kubernetes cluster."

  validation {
    condition     = var.controlplane_nodes_count > 0 && var.controlplane_nodes_count < 6
    error_message = "Controlplane node count for the cluster must be between [1, 5]."
  }
}

variable "worker_nodes_count" {
  type        = number
  default     = 2
  description = "Number of worker nodes in the Kubernetes cluster."

  validation {
    condition     = var.worker_nodes_count > 0 && var.worker_nodes_count < 20
    error_message = "Worker node count for the cluster must be between [1, 20)."
  }
}

variable "controlplane_machine_type" {
  type        = string
  description = "GCP machine type to use for the Kubernetes cluster controlplane node."

  validation {
    condition     = contains(["n1-standard-8", "n1-standard-4", "n1-standard-2", "n1-standard-1"], var.controlplane_machine_type)
    error_message = "Controlplane node machine type for the cluster must be from the predefined list."
  }
}

variable "worker_machine_type" {
  type        = string
  description = "GCP machine type to use for the Kubernetes cluster worker node."

  validation {
    condition     = contains(["n1-standard-8", "n1-standard-4", "n1-standard-2", "n1-standard-1"], var.worker_machine_type)
    error_message = "Worker nodes machine type for the cluster must be from the predefined list."
  }
}

variable "controlplane_image_type" {
  type        = string
  description = "Image to use for the Kubernetes controlplane node."

  validation {
    condition     = contains([
      "ubuntu-os-cloud/ubuntu-minimal-1604-lts",
      "ubuntu-os-cloud/ubuntu-minimal-1804-lts",
      "ubuntu-os-cloud/ubuntu-minimal-2004-lts",
      "cos-cloud/cos-77-lts",
      "cos-cloud/cos-81-lts",
      "cos-cloud/cos-85-lts"
    ], var.controlplane_image_type)
    error_message = "Controlplane image type is not valid."
  }
}

variable "worker_image_type" {
  type        = string
  description = "Image to use for the Kubernetes worker node."

  validation {
    condition     = contains([
      "ubuntu-os-cloud/ubuntu-minimal-1604-lts",
      "ubuntu-os-cloud/ubuntu-minimal-1804-lts",
      "ubuntu-os-cloud/ubuntu-minimal-2004-lts",
      "cos-cloud/cos-77-lts",
      "cos-cloud/cos-81-lts",
      "cos-cloud/cos-85-lts"
    ], var.worker_image_type)
    error_message = "Worker image type is not valid."
  }
}

variable "controlplane_machine_size" {
  type        = number
  default     = 25
  description = "Machine disk size for kuberentes controlplane nodes(in GB)."

  validation {
    condition     = var.controlplane_machine_size > 20 && var.controlplane_machine_size < 75
    error_message = "Controlplane node disk size for the cluster must be in range - (20, 75)."
  }
}

variable "worker_machine_size" {
  type        = number
  default     = 30
  description = "Number of worker nodes in the Kubernetes cluster."

  validation {
    condition     = var.worker_machine_size > 25 && var.worker_machine_size < 100
    error_message = "Worker node disk size for the cluster must be in range - (25, 100)."
  }
}