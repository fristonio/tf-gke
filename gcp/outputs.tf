output "cluster_name" {
  value       = var.cluster_name
  description = "Name of the created Kubernetes cluster"
}

output "cluster_kubeconfig" {
  value       = base64encode(tostring(data.google_storage_bucket_object_content.kubeconfig.content))
  description = "Kubeconfig to access the kubernetes cluster."
}
