data "aws_eks_cluster_auth" "cluster" {
  name  = aws_eks_cluster.eks_cluster.id
}

provider "kubernetes" {
  alias  = "eks_cluster"

  load_config_file = false

  host = "https://${aws_eks_cluster.eks_cluster.endpoint}"
  token = data.aws_eks_cluster_auth.cluster.token

  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
}


resource "kubernetes_service_account" "kubeconfig_sa" {
  provider = kuberentes.eks_cluster

  metadata {
    name      = "cluster-access-client-sa"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "kubeconfig_client" {
  provider = kuberentes.eks_cluster

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
  provider = kuberentes.eks_cluster

  depends_on = [ kubernetes_cluster_role_binding.kubeconfig_client ]

  metadata {
    name      = "cluster-access-client-sa"
    namespace = "kube-system"
  }
}

data "kubernetes_secret" "kubecfg" {
  provider = kuberentes.eks_cluster

  metadata {
    name      = data.kubernetes_service_account.kubecfg.default_secret_name
    namespace = "kube-system"
  }
}