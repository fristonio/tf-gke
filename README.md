# K8s Cluster terraform modules

> This repository contains a list of terraform modules that can be used to spin
CI cluster for Cilium using terraform-controller.

* [GKE managed K8s cluster](/gke)
* [EKS managed K8s cluster](/eks)
* [Self Mangaged K8s cluster on GCP](/gcp)

## Standard Output interface for modules

Each K8s cluster module must have the below mentioned output variables exposed
from the terraform configuration.

| Name | Description |
|------|-------------|
| cluster\_kubeconfig | Base64 encoded string of cluster kubeconfig. |
| cluster\_name | Name of the created Kubernetes cluster. |

## Note

* Make sure that the modules does not depends on components from other modules
 and are self sufficient to spin the cluster from within their own root
 directory.
