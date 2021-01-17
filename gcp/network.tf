locals {
  vpc_resources_count = var.vpc_configured ? 0 : 1
}

data "google_compute_network" "vpc" {
  depends_on = [ google_compute_network.vpc ]

  name = var.vpc_name
}

resource "google_compute_network" "vpc" {
  count = local.vpc_resources_count

  auto_create_subnetworks = true
  name                    = var.vpc_name
}

resource "google_compute_firewall" "cidr_to_worker" {
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "esp"
  }
  allow {
    protocol = "ah"
  }
  allow {
    protocol = "sctp"
  }

  name          = "${var.cluster_name}-cidr-to-worker"
  network       = data.google_compute_network.vpc.self_link

  source_ranges = [ var.cluster_cidr ]
  target_tags   = [ "${var.cluster_name}-worker-node" ]
}

resource "google_compute_firewall" "vpc_https_api" {
  allow {
    ports    = [ "6443" ]
    protocol = "tcp"
  }

  name          = "${var.cluster_name}-vpc-https-api"
  network       = data.google_compute_network.vpc.self_link

  source_ranges = [ "0.0.0.0/0" ]
  target_tags   = [ "${var.cluster_name}-controlplane-node" ]
}

resource "google_compute_firewall" "controlplane_node_health" {
  allow {
    ports    = [ "8558" ]
    protocol = "tcp"
  }

  name          = "${var.cluster_name}-controlplane-node-health"
  network       = data.google_compute_network.vpc.self_link

  source_ranges = [ "0.0.0.0/0" ]
  target_tags   = [ "${var.cluster_name}-controlplane-node" ]
}

resource "google_compute_firewall" "controlplane_to_controlplane" {
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "esp"
  }
  allow {
    protocol = "ah"
  }
  allow {
    protocol = "sctp"
  }

  name        = "${var.cluster_name}-controlplane-to-controlplane"
  network     = data.google_compute_network.vpc.self_link

  source_tags   = [ "${var.cluster_name}-controlplane-node" ]
  target_tags   = [ "${var.cluster_name}-controlplane-node" ]
}

resource "google_compute_firewall" "controlplane_to_worker" {
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "esp"
  }
  allow {
    protocol = "ah"
  }
  allow {
    protocol = "sctp"
  }

  name        = "${var.cluster_name}-controlplane-to-worker"
  network     = data.google_compute_network.vpc.self_link

  source_tags = [ "${var.cluster_name}-controlplane-node" ]
  target_tags = [ "${var.cluster_name}-worker-node" ]
}

resource "google_compute_firewall" "worker_to_controlplane" {
  allow {
    ports    = [ "6443" ]
    protocol = "tcp"
  }

  name        = "${var.cluster_name}-worker-to-controlplane"
  network     = data.google_compute_network.vpc.self_link

  source_tags = [ "${var.cluster_name}-worker-node" ]
  target_tags = [ "${var.cluster_name}-controlplane-node" ]
}

resource "google_compute_firewall" "worker_to_worker" {
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "esp"
  }
  allow {
    protocol = "ah"
  }
  allow {
    protocol = "sctp"
  }

  name        = "${var.cluster_name}-worker-to-worker"
  network     = data.google_compute_network.vpc.self_link

  source_tags = [ "${var.cluster_name}-worker-node" ]
  target_tags = [ "${var.cluster_name}-worker-node" ]
}

// Setup Firewall to allow ssh access to both controlplane and worker
// nodes.

resource "google_compute_firewall" "ssh_external_to_controlplane" {
  allow {
    ports    = [ "22" ]
    protocol = "tcp"
  }

  name          = "${var.cluster_name}-ssh-external-to-controlplane"
  network       = data.google_compute_network.vpc.self_link

  source_ranges = [ "0.0.0.0/0" ]
  target_tags   = [ "${var.cluster_name}-controlplane-node" ]
}

resource "google_compute_firewall" "ssh_external_to_worker" {
  allow {
    ports    = [ "22" ]
    protocol = "tcp"
  }

  name          = "${var.cluster_name}-ssh-external-to-worker"
  network       = data.google_compute_network.vpc.self_link

  source_ranges = [ "0.0.0.0/0" ]
  target_tags   = [ "${var.cluster_name}-controlplane-node" ]
}

// Add a forwarding rule for the Kubernetes API.

resource "google_compute_address" "k8s_api" {
  name = "${var.cluster_name}-k8s-api-addr"
}

resource "google_compute_forwarding_rule" "k8s_api" {
  ip_address  = google_compute_address.k8s_api.address
  ip_protocol = "TCP"
  name        = "${var.cluster_name}-k8s-api"
  port_range  = "6443-6443"

  target      = google_compute_target_pool.controlplane_pool.self_link
}
