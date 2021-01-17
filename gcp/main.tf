resource "random_string" "token_id" {
  length  = 6
  special = false
  upper   = false
}

resource "random_string" "token_secret" {
  length  = 16
  special = false
  upper   = false
}

locals {
  install_dir = "/var/lib/k8s-install"
  token       = "${random_string.token_id.result}.${random_string.token_secret.result}"

  k8s_apiserver_port = "6443"
}

resource "google_compute_instance_template" "workers" {
  name        = "${var.cluster_name}-workers-it"
  description = "The template for creating worker nodes for cluster ${var.cluster_name}."

  metadata = {
    "cluster_name" = var.cluster_name
    "node_type"    = "workers"
  }

  machine_type = var.worker_machine_type

  metadata_startup_script = templatefile("${path.module}/templates/startup-script.sh.tpl", {
    install_dir          = local.install_dir,
    controlplane         = false,
    primary_controlplane = false,
    cluster_cidr         = var.cluster_cidr,
    k8s_version          = var.kubernetes_version,
    kubeadm_token        = local.token,
    lb_addr              = google_compute_address.k8s_api.address,
    lb_port              = local.k8s_apiserver_port,
    node_image           = var.worker_image_type,
    cluster_bucket       = google_storage_bucket.cluster.url
  })

  can_ip_forward = true

  disk {
    auto_delete  = true
    boot         = true
    device_name  = "persistent-disks-0"
    disk_size_gb = var.worker_machine_size
    disk_type    = "pd-standard"
    mode         = "READ_WRITE"
    source_image = var.worker_image_type
    type         = "PERSISTENT"
  }

  network_interface {
    access_config {
    }

    network = data.google_compute_network.vpc.name
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  service_account {
    email  = google_service_account.sa.email
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = [ "${var.cluster_name}-worker-node" ]
}

# Instance template for primary controlplane node of the cluster.
resource "google_compute_instance_template" "controlplane_primary" {
  name        = "${var.cluster_name}-controlplane-primary-it"
  description = "The template for creating primary controlplane node for cluster ${var.cluster_name}."

  metadata = {
    "cluster_name" = var.cluster_name
    "node_type"    = "controlplane"
  }

  machine_type = var.controlplane_machine_type

  metadata_startup_script = templatefile("${path.module}/templates/startup-script.sh.tpl", {
    install_dir          = local.install_dir,
    controlplane         = true,
    primary_controlplane = true,
    cluster_cidr         = var.cluster_cidr,
    k8s_version          = var.kubernetes_version,
    kubeadm_token        = local.token,
    lb_addr              = google_compute_address.k8s_api.address,
    lb_port              = local.k8s_apiserver_port,
    node_image           = var.controlplane_image_type,
    cluster_bucket       = google_storage_bucket.cluster.url
  })

  can_ip_forward = true
  
  disk {
    auto_delete  = true
    boot         = true
    device_name  = "persistent-disks-0"
    disk_size_gb = var.controlplane_machine_size
    disk_type    = "pd-standard"
    mode         = "READ_WRITE"
    source_image = var.controlplane_image_type
    type         = "PERSISTENT"
  }

  network_interface {
    access_config {
    }

    network = data.google_compute_network.vpc.name
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  service_account {
    email  = google_service_account.sa.email
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_write"
    ]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = [ "${var.cluster_name}-controlplane-node" ]
}

# Instance template for secondary controlplane node of the cluster.
resource "google_compute_instance_template" "controlplane_secondary" {
  depends_on = [ google_compute_region_instance_group_manager.controlplane_primary ]
  # Only create this template instance when the controlplane node counts is greater
  # than 1.
  count = var.controlplane_nodes_count > 1 ? 1 : 0

  name        = "${var.cluster_name}-controlplane-secondary-it"
  description = "The template for creating secondary controlplane node for cluster ${var.cluster_name}."

  metadata = {
    "cluster_name" = var.cluster_name
    "node_type"    = "controlplane"
  }

  machine_type = var.controlplane_machine_type

  metadata_startup_script = templatefile("${path.module}/templates/startup-script.sh.tpl", {
    install_dir          = local.install_dir,
    controlplane         = true,
    primary_controlplane = false,
    cluster_cidr         = var.cluster_cidr,
    k8s_version          = var.kubernetes_version,
    kubeadm_token        = local.token,
    lb_addr              = google_compute_address.k8s_api.address,
    lb_port              = "6443",
    node_image           = var.controlplane_image_type,
    cluster_bucket       = google_storage_bucket.cluster.url
  })

  can_ip_forward = true

  disk {
    auto_delete  = true
    boot         = true
    device_name  = "persistent-disks-0"
    disk_size_gb = var.controlplane_machine_size
    disk_type    = "pd-standard"
    mode         = "READ_WRITE"
    source_image = var.controlplane_image_type
    type         = "PERSISTENT"
  }

  network_interface {
    access_config {
    }

    network = data.google_compute_network.vpc.name
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  service_account {
    email  = google_service_account.sa.email
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = [ "${var.cluster_name}-controlplane-node" ]
}


resource "google_compute_target_pool" "controlplane_pool" {
  name = var.cluster_name

   health_checks = [
    google_compute_http_health_check.controlplane_node.name,
  ]
}

/* Support for HTTPS health check is not in yet.
resource "google_compute_health_check" "apiserver" {
  name         = "${var.cluster_name}-apiserver-hc"

  timeout_sec        = 1
  check_interval_sec = 1

  https_health_check {
    port          = "6443"
    request_path  = "/readyz"
  }
}
*/

resource "google_compute_http_health_check" "controlplane_node" {
  name               = "${var.cluster_name}-controlplane-node-health"

  port               = 8558
  request_path       = "/"
  check_interval_sec = 3
  timeout_sec        = 3
}

data "google_compute_zones" "available" {
  region = var.cluster_location
}

resource "google_compute_region_instance_group_manager" "controlplane_primary" {
  depends_on = [
    google_storage_bucket_iam_binding.object_creator,
    google_storage_bucket_iam_binding.object_viewer,
  ]

  base_instance_name = "${var.cluster_name}-controlplane-primary"
  name               = "${var.cluster_name}-controlplane-primary-ig"

  region = var.cluster_location

  target_pools       = [
    google_compute_target_pool.controlplane_pool.self_link
  ]
  target_size        = 1

  version {
    instance_template = google_compute_instance_template.controlplane_primary.self_link
  }

  # Restrict this instance to the first zone we got from the available zones.
  distribution_policy_zones = [ data.google_compute_zones.available.names[0] ]
  wait_for_instances        = true
}

resource "google_compute_region_instance_group_manager" "controlplane_secondary" {
  depends_on = [
    google_compute_region_instance_group_manager.controlplane_primary,
    google_storage_bucket_iam_binding.object_creator,
    google_storage_bucket_iam_binding.object_viewer,
  ]
  count = var.controlplane_nodes_count > 1 ? 1 : 0

  region = var.cluster_location

  base_instance_name = "${var.cluster_name}-controlplane-secondary"
  name               = "${var.cluster_name}-controlplane-secondary-ig"

  target_size        = var.controlplane_nodes_count - 1

  version {
    instance_template = google_compute_instance_template.controlplane_secondary[0].self_link
  }

  distribution_policy_zones = data.google_compute_zones.available.names
  wait_for_instances        = true
}

resource "google_compute_region_instance_group_manager" "worker" {
  depends_on = [
    google_compute_region_instance_group_manager.controlplane_primary,
    google_storage_bucket_iam_binding.object_creator,
    google_storage_bucket_iam_binding.object_viewer,
  ]

  base_instance_name = "${var.cluster_name}-worker"
  name               = "${var.cluster_name}-worker-ig"

  region = var.cluster_location

  target_size        = var.worker_nodes_count

  version {
    instance_template = google_compute_instance_template.workers.self_link
  }

  distribution_policy_zones = data.google_compute_zones.available.names
  wait_for_instances        = true
}
