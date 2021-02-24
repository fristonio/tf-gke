output "cluster_name" {
  value       = var.cluster_name
  description = "Name of the underlying GKE cluster"
}

output "cluster_kubeconfig" {
  value       = base64encode(<<EOT
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${data.google_container_cluster.k8s_cluster.master_auth.0.cluster_ca_certificate}
    server: https://${data.google_container_cluster.k8s_cluster.endpoint}
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

output "cluster_cidr" {
  value       = data.google_container_cluster.k8s_cluster.cluster_ipv4_cidr
  description = "IPv4 CIDR for the created Kubernetes cluster."
}
