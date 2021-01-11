# K8s Cluster terraform modules

> This repository contains a list of terraform modules that can be used to spin
CI cluster for Cilium using terraform-controller.

* [GKE managed K8s cluster](/gke)
* [EKS managed K8s cluster](/eks)

## Note

* Make sure that the modules does not depends on components from other modules
 and are self sufficient to spin the cluster from within their own root
 directory.
