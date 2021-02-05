output "cluster_name" {
  value       = google_container_cluster.k8s_cluster.name
  description = "Name of the created GKE cluster."
}

output "cluster_location" {
  value       = google_container_cluster.k8s_cluster.location
  description = "Location the GKE cluster was created in."
}

output "cluster_endpoint" {
  value       = google_container_cluster.k8s_cluster.endpoint
  description = "Management GKE cluster endpoint."
}

output "configured" {
  value       = google_container_cluster.k8s_cluster.name != ""
  description = "Indicator of whether the cluster was created or not."
}

output "cluster_cidr" {
  value       = google_container_cluster.k8s_cluster.cluster_ipv4_cidr
  description = "IPv4 CIDR for the created Kubernetes cluster."
}
