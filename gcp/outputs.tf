output "cluster_name" {
  value       = var.cluster_name
  description = "Name of the created Kubernetes cluster"
}

output "cluster_kubeconfig" {
  value       = base64encode(data.http.kubeconfig.body)
  description = "Kubeconfig to access the kubernetes cluster."
}
