locals {
  initial_node_count = var.remove_default_node_pool ? 1 : var.default_nodes_count
}

data "google_container_engine_versions" "cluster" {
  location       = var.cluster_location
  version_prefix = var.kubernetes_version != "latest" ? var.kubernetes_version : ""
}

resource "google_container_cluster" "k8s_cluster" {
  name               = var.cluster_name
  location           = var.cluster_location

  min_master_version = data.google_container_engine_versions.cluster.latest_master_version

  initial_node_count       = local.initial_node_count
  remove_default_node_pool = var.remove_default_node_pool
  node_locations           = toset(var.default_node_zones)

  network = var.vpc_name

  # The subnet should have the same name as the region for the
  # k8s cluster.
  subnetwork = var.cluster_subnet

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = true
    }
  }

  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }

  timeouts {
    create = "30m"
    update = "40m"
  }

  lifecycle {
    prevent_destroy = false
  }
}