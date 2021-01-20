module "vpc" {
  source = "./../cluster/vpc"

  vpc_name = var.vpc_name
}
