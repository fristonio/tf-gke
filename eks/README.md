# EKS cluster

> This module can be used to provision an EKS cluster on AWS using terraform.

## VPC

Each EKS cluster created from this module will live under an AWS VPC. A VPC
with required configuration can be created using VPC submodule provided under
[vpc](./vpc).

If you want to use a previously created VPC in AWS make sure that the VPC
meets all the requirements for an EKS cluster, listed
[here](https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html).

## Cluster

To run the cluster there are currently two ways configured. The first is a
more granular process while the other makes use of an external terraform
module to spin the entire cluster.

### AWS terraform provider

This method for more granular use is broken down into two steps.

#### K8s controlplane

The module for configuring the EKS control plane lives [here](./controlplane).

#### K8s nodegroup

The module for configuring the EKS NodeGroup lives [here](./nodegroup).