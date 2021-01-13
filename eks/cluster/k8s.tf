data "aws_eks_cluster_auth" "cluster" {
  depends_on = [ module.nodegroup ]

  name  = var.cluster_name
}

data "aws_eks_cluster" "cluster" {
  depends_on = [ module.nodegroup ]

  name  = var.cluster_name
}


provider "kubernetes" {
  alias  = "eks_cluster"

  load_config_file = false

  host = data.aws_eks_cluster.cluster.endpoint
  token = data.aws_eks_cluster_auth.cluster.token

  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
}

resource "kubernetes_service_account" "kubeconfig_sa" {
  provider = kubernetes.eks_cluster

  metadata {
    name      = "cluster-access-client-sa"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "kubeconfig_client" {
  provider = kubernetes.eks_cluster

  depends_on = [ kubernetes_service_account.kubeconfig_sa ]

  metadata {
    name = "cluster-access-sa-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "cluster-access-client-sa"
    namespace = "kube-system"
  }
}

data "kubernetes_service_account" "kubecfg" {
  provider = kubernetes.eks_cluster

  depends_on = [ kubernetes_cluster_role_binding.kubeconfig_client ]

  metadata {
    name      = "cluster-access-client-sa"
    namespace = "kube-system"
  }
}

data "kubernetes_secret" "kubecfg" {
  provider = kubernetes.eks_cluster

  metadata {
    name      = data.kubernetes_service_account.kubecfg.default_secret_name
    namespace = "kube-system"
  }
}
