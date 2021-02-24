locals {
  default_nodes_count = var.use_default_nodepool ? var.node_count : 1
}

module "vpc" {
  source = "./vpc"

  count = var.vpc_configured || var.controlplane_configured ? 0 : 1

  vpc_name = var.vpc_name
}

module "controlplane" {
  source = "./controlplane"

  count = var.controlplane_configured ? 0 : 1

  depends_on = [ module.vpc ]

  project_id         = var.project_id
  vpc_name           = var.vpc_name
  cluster_subnet     = var.region
  cluster_location   = var.cluster_location
  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version

  remove_default_node_pool = !var.use_default_nodepool
  default_nodes_count      = local.default_nodes_count
}

module "nodepool" {
  source = "./nodepool"

  // Only create this nodepool if we are not using the default nodepool.
  count = var.use_default_nodepool ? 0 : 1

  depends_on = [ module.controlplane ]

  cluster_location   = var.cluster_location
  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  node_zones         = var.node_zones
  node_machine_type  = var.node_machine_type
  node_image_type    = var.node_image_type
  node_count         = var.node_count
}
