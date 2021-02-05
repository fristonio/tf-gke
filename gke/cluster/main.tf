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
}

module "nodepool" {
  source = "./nodepool"

  depends_on = [ module.controlplane ]

  cluster_location   = var.cluster_location
  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  node_zones         = var.node_zones
  node_machine_type  = var.node_machine_type
  node_image_type    = var.node_image_type
  node_count         = var.node_count
}
