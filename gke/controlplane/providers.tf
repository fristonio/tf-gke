terraform {
  required_version = ">= 0.14.0"

  required_providers {
    google = {
      version = ">= 3.52.0"
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  credentials = base64decode(var.svc_account_key)
  project     = var.project_id
  region      = var.cluster_location
}
