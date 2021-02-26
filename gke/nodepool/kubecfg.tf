data "google_client_config" "default" {}

data "google_container_cluster" "k8s_cluster" {
  depends_on = [ module.nodepool ]

  name               = var.cluster_name
  location           = var.cluster_location
}

provider "kubernetes" {
  alias  = "gke_cluster"

  load_config_file = false

  host = "https://${data.google_container_cluster.k8s_cluster.endpoint}"
  token = data.google_client_config.default.access_token

  cluster_ca_certificate = base64decode(data.google_container_cluster.k8s_cluster.master_auth.0.cluster_ca_certificate)
}

resource "kubernetes_service_account" "kubeconfig_sa" {
  provider = kubernetes.gke_cluster

  depends_on = [ module.nodepool ]

  metadata {
    name      = "cluster-access-client-ng-sa"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "kubeconfig_client" {
  provider = kubernetes.gke_cluster

  depends_on = [ kubernetes_service_account.kubeconfig_sa ]

  metadata {
    name = "cluster-access-ng-sa-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "cluster-access-client-ng-sa"
    namespace = "kube-system"
  }
}

data "kubernetes_service_account" "kubecfg" {
  provider = kubernetes.gke_cluster

  depends_on = [ kubernetes_cluster_role_binding.kubeconfig_client ]

  metadata {
    name      = "cluster-access-client-ng-sa"
    namespace = "kube-system"
  }
}

data "kubernetes_secret" "kubecfg" {
  provider = kubernetes.gke_cluster

  metadata {
    name      = data.kubernetes_service_account.kubecfg.default_secret_name
    namespace = "kube-system"
  }
}
