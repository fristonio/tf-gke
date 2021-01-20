module "nodegroup" {
  source = "./../cluster/nodegroup"

  cluster_name = var.cluster_name
  subnets      = var.subnets

  desired_size = var.desired_size
  max_size     = var.max_size
  min_size     = var.min_size
  disk_size    = var.disk_size

  instance_type = var.instance_type
  ami_type      = var.ami_type
}
