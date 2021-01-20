#!/bin/bash

set -eu pipefail

TF_MODULES=(
    "eks/cluster"
    "eks/vpc"
    "eks/controlplane"
    "eks/nodegroup"
    "gcp"
    "gke/cluster"
    "gke/vpc"
    "gke/controlplane"
    "gke/nodepool"
)

ROOT_DIR=$(pwd)
for module in "${TF_MODULES[@]}"
do
    echo " ------------------------------------------------------- "
    echo "[+] Validating terraform module - ${module}"
    cd "${module}"
    rm -rf .terraform/ .terraform.tfstate .terraform.tfstate.backup .terraform.lock.hcl
    terraform init
    terraform validate
    rm -rf .terraform/ .terraform.tfstate .terraform.tfstate.backup .terraform.lock.hcl
    cd "${ROOT_DIR}"
    echo " ------------------------------------------------------- "
done
