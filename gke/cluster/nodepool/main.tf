data "google_container_engine_versions" "cluster" {
  location       = var.cluster_location
  version_prefix = var.kubernetes_version != "latest" ? var.kubernetes_version : ""
}

resource "google_container_node_pool" "k8s_cluster" {
  name               = "${var.cluster_name}-np"
  location           = var.cluster_location
  cluster            = var.cluster_name

  version = data.google_container_engine_versions.cluster.latest_master_version

  node_locations = toset(var.node_zones)

  node_count = var.node_count

  node_config {
    machine_type = var.node_machine_type
    image_type   = var.node_image_type

    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }

    labels = {
      node-pool = "default-${var.cluster_name}"
      cluster-name = var.cluster_name
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  timeouts {
    create = "30m"
    update = "40m"
  }

  lifecycle {
    create_before_destroy = true
  }
}