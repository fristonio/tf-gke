# terraform-example-gke

Terrafoerm module to spin a GKE cluster. This will create a new VPC and subnet
for the K8s Cluster. The default node pool for the cluster is removed and a new
node pool with the provided configuration is attached to the cluster.

The terraform module will output the kubeconfig for `client` user in the
cluster. It will also automatically bind `cluster-admin` role to this user so
the kubeconfig have clusterwide access.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| google | n/a |
| google-beta | n/a |
| kuberentes.gke\_cluster | n/a |
| template | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_location | Location to create the GKE clsuter in. | `string` | n/a | yes |
| cluster\_name | Name of the GKE cluster. | `string` | n/a | yes |
| node\_count | Number of worker nodes in the Kubernetes cluster. | `string` | `"1"` | no |
| node\_image\_type | Image to use for the Kubernetes node | `string` | n/a | yes |
| node\_machine\_type | GCP machine type to use for the Kubernetes cluster node | `string` | n/a | yes |
| node\_zones | A list of zones in the location provided in which to launch the nodes. | `list(string)` | n/a | yes |
| project\_id | GCP project to create the Kuberentes cluster in | `string` | n/a | yes |
| subnet\_cidr | Subnet CIDR to create for the location in the VPC. | `string` | `"10.128.0.0/20"` | no |
| svc\_account\_key | Service account key in Base64 encoded format. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_endpoint | Management GKE cluster endpoint |
| cluster\_kubeconfig | Base64 encoded version of cluster kubeconfig |
| cluster\_name | Name of the created GKE cluster |
| cluster\_zone | Location the GKE cluster was created in |
