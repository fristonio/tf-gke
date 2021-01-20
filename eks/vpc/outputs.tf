output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of the created VPC."
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "IDs of the associated public subnets."
}

output "clusters_subnets" {
  value       = module.vpc.clusters_subnets
  description = "A list of subnet ids that can be used for creating EKS clusters."
}
