resource "google_service_account" "sa" {
  account_id   = "${var.cluster_name}-sa"
  display_name = "Service Account for the k8s cluster instances - ${var.cluster_name}"
}

resource "google_storage_bucket" "cluster" {
  name          = "${var.cluster_name}-data"
  force_destroy = true
}

resource "google_storage_bucket_iam_binding" "object_viewer" {
  bucket = google_storage_bucket.cluster.name
  role = "roles/storage.objectViewer"

  members = [
    "serviceAccount:${google_service_account.sa.email}",
  ]
}

resource "google_storage_bucket_iam_binding" "object_creator" {
  depends_on = [ google_storage_bucket.cluster ]

  bucket = google_storage_bucket.cluster.name
  role = "roles/storage.objectCreator"

  members = [
    "serviceAccount:${google_service_account.sa.email}",
  ]
}