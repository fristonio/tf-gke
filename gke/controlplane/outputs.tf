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
