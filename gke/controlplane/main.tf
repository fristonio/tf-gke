module "controlplane" {
  source = "./../cluster/controlplane"

  project_id         = var.project_id
  vpc_name           = var.vpc_name
  cluster_subnet     = var.region
  cluster_location   = var.cluster_location
  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
}
