output "cluster_name" {
  value       = var.cluster_name
  description = "Name of the created EKS cluster"
}

output "nodegroup_id" {
  value       = aws_eks_node_group.eks_ng.id
  description = "ID of the created EKS nodegroup."
}
