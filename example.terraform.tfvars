cluster_location  = "us-central1"
cluster_name      = "gke-cluster"
node_count        = "1"
node_image_type   = "COS_CONTAINERD"
node_machine_type = "n2-standard2"
node_zones        = [ "us-central1-a", "us-central1-b" ]
project_id        = ""
subnet_cidr       = "10.128.0.0/20"
svc_account_key   = "JSON encoded service account key"