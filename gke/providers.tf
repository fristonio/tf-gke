terraform {
  required_version = ">= 0.14.0"

  required_providers {
    google = {
      version = ">= 3.52.0"
      source = "hashicorp/aws"
    }

    google-beta = {
      version = ">= 3.52.0"
      source = "hashicorp/aws"
    }

    kubernetes = {
      version = ">= 1.13.3"
      source = "hashicorp/kubernetes"
    }
  }
}


provider "google" {
  credentials = base64decode(var.svc_account_key)
  project     = var.project_id
  region      = var.cluster_location
}

provider "google-beta" {
  credentials = base64decode(var.svc_account_key)
  project     = var.project_id
  region      = var.cluster_location
}
