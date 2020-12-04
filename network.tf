resource "google_compute_network" "k8s_cluster_vpc" {
  name                    = var.cluster_name
  # it is highly beneficial to let terraform manage all subnets,
  # as otherwise when changes are needed it's not easily possible
  # to import subnets that were created outside of terraform
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "k8s_cluster_subnets" {
  for_each      = var.subnets
  name          = each.key
  region        = each.key
  ip_cidr_range = each.value
  network       = google_compute_network.k8s_cluster_vpc.self_link
}
