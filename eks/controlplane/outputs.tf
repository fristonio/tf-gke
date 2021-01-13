output "cluster_name" {
  value       = var.cluster_name
  description = "Name of the created EKS cluster"
}

output "cluster_version" {
  value       = aws_eks_cluster.eks_cluster.version
  description = "Version of the created EKS cluster"
}

output "cluster_subnets" {
  value       = var.subnets
  description = "Subnets associated with the cluster."
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.eks_cluster.endpoint
  description = "Endpoint for the created EKS cluster."
  sensitive   = true
}
