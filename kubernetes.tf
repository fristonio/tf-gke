data "google_client_config" "default" {}

provider "kubernetes" {
  load_config_file = false

  host = "https://${google_container_cluster.k8s_cluster.endpoint}"
  token = data.google_client_config.default.access_token

  cluster_ca_certificate = base64decode(google_container_cluster.k8s_cluster.master_auth.0.cluster_ca_certificate)
}

# The kubeconfig we exported for the container cluster corresponds to the
# client user which have no access in the cluster.
# Create a cluster role binding which binds this user to the cluster-admin.
resource "kubernetes_cluster_role_binding" "kubeconfig_client" {
  metadata {
    name = "cluster-access-client-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = "client"
  }
}