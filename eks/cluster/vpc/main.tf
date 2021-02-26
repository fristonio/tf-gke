data "aws_availability_zones" "available" {}

locals {
  // Break the VPC CIDR provided for the VPC to 9 subnet CIDR triplets.
  // We can use these subnet cidrs pairs for EKS clsuters.
  // The first triplet is used as public subnet in the VPC and the rest can
  // be used for creating EKS clusters.
  subnets = [
    for cidr_block in cidrsubnets(var.vpc_cidr, 6, 6, 6, 6, 6, 6, 6, 6, 6) : cidrsubnets(cidr_block, 2, 2, 2)
  ]

  all_subnets = sort(flatten(local.subnets))
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.64.0"

  name                 = var.vpc_name
  cidr                 = var.vpc_cidr

  // The VPC spans 3 of the availability zones for the provided region in 
  // the AWS configuration.
  // Each AZ will have a public subnet associated with it.
  azs                  = slice(data.aws_availability_zones.available.names, 0, 3)

  // This is the first block without flattening the the subnets.
  public_subnets       = slice(local.all_subnets, 0, 3)
  private_subnets      = slice(local.all_subnets, 3, length(local.all_subnets))

  // Configure NAT for this VPC. Here we are configuring one NAT
  // instance for each availabilitiy zone configured for this VPC.
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true

  // These tags are required on the Subnets for EKS cluster to be able
  // to use them.
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = merge(
    var.tags,
    {
      Owner       = "terraform"
      Environment = "eks-clusters"
    },
  )
}
