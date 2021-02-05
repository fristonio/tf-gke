output "cluster_name" {
  value       = module.controlplane.cluster_name
  description = "Name of the created GKE cluster."
}

output "cluster_location" {
  value       = module.controlplane.cluster_location
  description = "Location the GKE cluster was created in."
}

output "cluster_endpoint" {
  value       = module.controlplane.cluster_endpoint
  description = "Management GKE cluster endpoint."
}

output "cluster_cidr" {
  value       = module.controlplane.cluster_cidr
  description = "IPv4 CIDR for the created Kubernetes cluster controlplane."
}
