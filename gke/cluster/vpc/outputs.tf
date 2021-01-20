output "vpc_name" {
  value       = var.vpc_name
  description = "Name of the VPC created."
}

output "configured" {
  value       = google_compute_network.k8s_cluster_vpc.name != ""
  description = "If the VPC configuration was successful, this is used as an input for other modules."
}