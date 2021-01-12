output "cluster_name" {
  value       = var.cluster_name
  description = "Name of the created EKS cluster"
}

output "ng_id" {
  value       = aws_eks_node_group.eks_ng.id
  description = "ID of the created EKS nodegroup."
}

output "cluster_kubeconfig" {
  value       = base64encode(<<EOT
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${data.aws_eks_cluster.cluster.certificate_authority[0].data}
    server: ${data.aws_eks_cluster.cluster.endpoint}
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
)
  description = "Kubeconfig to access the kubernetes cluster."
}
