module "controlplane" {
  source = "./../cluster/controlplane"

  cluster_name = var.cluster_name
  subnets      = var.subnets

  kubernetes_version = var.kubernetes_version
}
