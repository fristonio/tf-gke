module "nodepool" {
  source = "./../cluster/nodepool"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  location           = var.cluster_location
  node_zones         = var.node_zones
  node_machine_type  = var.node_machine_type
  node_image_type    = var.node_image_type
  node_count         = var.node_count
}
