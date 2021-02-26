locals {
  cluster_subnet = length(var.subnets) > 0 ? var.subnets : var.vpc_clusters_subnets[var.cluster_index]
}

module "controlplane" {
  source = "./../cluster/controlplane"

  cluster_name = var.cluster_name
  subnets      = local.cluster_subnet

  kubernetes_version = var.kubernetes_version
}
