resource "google_compute_network" "k8s_cluster_vpc" {
  provider = google-beta

  name                    = var.cluster_name
  # it is highly beneficial to let terraform manage all subnets,
  # as otherwise when changes are needed it's not easily possible
  # to import subnets that were created outside of terraform
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "k8s_cluster_subnets" {
  provider = google-beta

  depends_on = [ google_compute_network.k8s_cluster_vpc ]

  name          = var.cluster_location
  region        = var.cluster_location
  ip_cidr_range = var.subnet_cidr
  network       = google_compute_network.k8s_cluster_vpc.id
}
