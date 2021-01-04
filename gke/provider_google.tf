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
