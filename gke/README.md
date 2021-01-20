# GKE cluster

> This module will create a GKE cluster.

* [VPC](./vpc) - Standalone module for VPC for the GKE cluster.
* [Controlplane](./controlplane) - Standalone GKE controlplane without any nodepool.
* [NodePool](./nodepool) - Standalone nodepool to associate with a K8s cluster.
* [Cluster](./cluster) - Complete GKE cluster with everything in one place including network/controlplane/nodepool.
