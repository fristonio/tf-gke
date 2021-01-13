output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of the created VPC."
}

output "configured" {
  value       = module.vpc.vpc_id != ""
  description = "Dummy output variable to specify if VPC was configured."
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnets
  description = "IDs of the associated public subnets."
}

output "clusters_subnets" {
  value       = chunklist(module.vpc.private_subnets, 3)
  description = "A list of subnet ids that can be used for creating EKS clusters."
}
