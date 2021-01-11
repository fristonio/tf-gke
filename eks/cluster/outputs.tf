output "cluster_name" {
  value       = var.cluster_name
  description = "Name of the created EKS cluster"
}

output "nodegroup_id" {
  value       = aws_eks_node_group.eks_ng.id
  description = "ID of the created EKS nodegroup."
}


output "cluster_version" {
  value       = aws_eks_cluster.eks_cluster.version
  description = "Version of the created EKS cluster"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.eks_cluster.endpoint
  description = "Endpoint for the created EKS cluster."
  sensitive   = true
}

output "cluster_kubeconfig" {
  value       = <<EOT
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${aws_eks_cluster.eks_cluster.certificate_authority[0].data}
    server: https://${aws_eks_cluster.eks_cluster.endpoint}
  name: kube-client
contexts:
- context:
    cluster: kube-client
    user: kube-client
  name: kube-client
current-context: kube-client
kind: Config
preferences: {}
users:
- name: kube-client
  user:
    token: ${data.kubernetes_secret.kubecfg.data.token}
EOT
  description = "Kubeconfig to access the kubernetes cluster."
}
