data "google_container_cluster" "k8s_cluster" {
  name     = var.cluster_name
  location = var.cluster_location
}
