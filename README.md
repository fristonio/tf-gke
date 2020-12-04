# terraform-example-gke

A sample terraform module to spin up a GKE cluster.

Required variables:

```
cluster_name      = "gke-example-cluster"

cluster_location  = "us-central1"

node_machine_type = "n2-standard-2"

node_image_type   = "COS_CONTAINERD"

node_count        = "1"

project_id        = "xxxxx"

svc_account_key   = "dGVzdAo="
```