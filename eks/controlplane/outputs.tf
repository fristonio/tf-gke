output "cluster_name" {
  value       = module.controlplane.cluster_name
  description = "Name of the created EKS cluster"
}

output "cluster_version" {
  value       = module.controlplane.cluster_version
  description = "Version of the created EKS cluster"
}

output "cluster_subnets" {
  value       = module.controlplane.cluster_subnets
  description = "Subnets associated with the cluster."
}

output "cluster_endpoint" {
  value       = module.controlplane.cluster_endpoint
  description = "Endpoint for the created EKS cluster."
  sensitive   = true
}
