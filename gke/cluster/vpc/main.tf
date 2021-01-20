resource "google_compute_network" "k8s_cluster_vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = true
}
