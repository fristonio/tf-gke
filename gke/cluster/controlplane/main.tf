data "google_container_engine_versions" "cluster" {
  location       = var.cluster_location
  version_prefix = var.kubernetes_version != "latest" ? var.kubernetes_version : ""
}

resource "google_container_cluster" "k8s_cluster" {
  name               = var.cluster_name
  location           = var.cluster_location

  min_master_version = data.google_container_engine_versions.cluster.latest_master_version

  # Create a node pool with one node and immediately delete it so that we can
  # use our own managed node pool.
  initial_node_count = 1
  remove_default_node_pool = true

  network            = var.vpc_name

  # The subnet should have the same name as the region for the
  # k8s cluster.
  subnetwork         = var.cluster_location

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