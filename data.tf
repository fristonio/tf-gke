data "template_file" "kubeconfig" {
  template = file("${path.module}/kubeconfig.tpl")

  vars {
    cluster_name           = var.cluster_name
    cluster_endpoint       = google_container_cluster.k8s_cluster.endpoint

    cluster_ca_certificate = google_container_cluster.k8s_cluster.master_auth.0.cluster_ca_certificate
    client_cert            = google_container_cluster.k8s_cluster.master_auth.0.client_certificate
    client_key             = google_container_cluster.k8s_cluster.master_auth.0.client_key
  }
}
