output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of the created VPC."
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnets
  description = "IDs of the associated public subnets."
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnets
  description = "IDs of the associated private subnets for VPC."
}
