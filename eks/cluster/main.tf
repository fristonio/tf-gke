locals {
  cluster_subnet = length(var.subnets) > 0 ? var.subnets : module.vpc[0].clusters_subnets[var.cluster_index]
}

module "nodegroup" {
  source = "./../nodegroup"

  depends_on = [ module.controlplane ]

  aws_region     = var.aws_region
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key

  cluster_name = var.cluster_name
  subnets      = local.cluster_subnet

  desired_size = var.desired_size
  max_size     = var.max_size
  min_size     = var.min_size
  disk_size    = var.disk_size

  instance_type = var.instance_type
  ami_type      = var.ami_type
}

module "controlplane" {
  source = "./../controlplane"

  depends_on = [ module.vpc ]

  count = var.contorlplane_configured ? 0 : 1 

  aws_region     = var.aws_region
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key

  cluster_name = var.cluster_name
  subnets      = local.cluster_subnet

  kubernetes_version = var.kubernetes_version
}

module "vpc" {
  source = "./../vpc"

  count = var.vpc_configured ? 0 : 1

  aws_region     = var.aws_region
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key

  vpc_name       = "${var.cluster_name}-vpc"
  vpc_cidr       = var.vpc_cidr
}
