module "vpc" {
  source = "./../cluster/vpc"

  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr
  tags     = var.tags
}
