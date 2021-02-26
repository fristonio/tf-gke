output "cluster_name" {
  value       = var.cluster_name
  description = "Name of the underlying GKE cluster."
}

output "name" {
  value       = google_container_node_pool.k8s_cluster.name
  description = "Name of the GKE nodepool for the cluster."
}
