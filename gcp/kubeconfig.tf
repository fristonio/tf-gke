
# Wait for Kubernetes admin config to be propagated to the cloud
# storage.
resource "null_resource" "apiserver_ready" {
  depends_on = [ 
    google_compute_region_instance_group_manager.worker,
    google_compute_region_instance_group_manager.controlplane_secondary
  ]

  provisioner "local-exec" {
    # This script assumes that we have netcat and /bin/bash installed.
    # We do a small sleep here.
    command = "./scripts/check-apiserver.sh -h ${google_compute_address.k8s_api.address} -p 6443 -t 180 -- sleep 5"
  }
}

data "google_storage_bucket_object_content" "kubeconfig" {
  depends_on = [ 
    null_resource.apiserver_ready
  ]

  name   = "admin.conf"
  bucket = google_storage_bucket.cluster.name
}
