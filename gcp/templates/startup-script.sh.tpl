#!/bin/bash

INSTALL_DIR="${install_dir}"

BIN_DIR="/usr/bin"
OS="${node_image}"

function ensure_install_dir() {
  mkdir -p "$${INSTALL_DIR}"

  cd "$${INSTALL_DIR}" || exit 0
}

# Retry a download until we get it. args: name, sha, url1, url2...
function download_to_file() {
  local -r file="$1"
  local -r url="$2"
  shift 2

  commands=(
    "curl -f --ipv4 --compressed -Lo "$${file}" --connect-timeout 20 --retry 6 --retry-delay 10"
    "curl -f --ipv4 -Lo "$${file}" --connect-timeout 20 --retry 6 --retry-delay 10"
  )

  for cmd in "$${commands[@]}"; do
    echo "Attempting download with: $${cmd} $${url}"
    if ! ($${cmd} "$${url}"); then
      echo "== Download failed with $${cmd} $${url} =="
      continue
    fi

    echo "== Downloaded $${url} =="
    return
  done

  echo "All downloads failed; cannot proceed"
  exit 1
}

# Setup systemctl setting for the node.
cat <<EOF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sysctl --system

case "$${OS}" in
  "ubuntu-os-cloud/ubuntu-minimal-1604-lts")
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common conntrack iptables
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key --keyring /etc/apt/trusted.gpg.d/docker.gpg add -
    sudo add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) \
      stable"
    apt-get update && apt-get install -y containerd.io
    ;;

  "ubuntu-os-cloud/ubuntu-minimal-1804-lts"|"ubuntu-os-cloud/ubuntu-minimal-2004-lts")
    apt-get update && apt-get install -y containerd conntrack iptables
    ;;

  *)
    echo "Considering containered to be configured by default for OS provided: $${OS}"
    exit 1
    ;;
esac

ensure_install_dir

k8s_major=$(echo "${k8s_version}" | cut -d. -f1)
k8s_minor=$(echo "${k8s_version}" | cut -d. -f2)

K8S_MINOR_VERSION="$${k8s_major}.$${k8s_minor}"

CRITOOLS_VERSION="$${k8s_major}.$${k8s_minor}.0"
CNI_VERSION="v0.8.1"

KUBEADM_PRIMARY_CP_CONFIG_V1BETA1=$(cat <<-EOF
---
apiVersion: kubeadm.k8s.io/v1beta1
kind: InitConfiguration
localAPIEndpoint:
  bindPort: ${lb_port}
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: "${kubeadm_token}"
  ttl: 2h0m0s
  usages:
  - signing
  - authentication
nodeRegistration:
  criSocket: "unix:///run/containerd/containerd.sock"
EOF
)

KUBEADM_SECONDARY_CP_CONFIG_V1BETA1=$(cat <<-EOF
---
apiVersion: kubeadm.k8s.io/v1beta1
kind: JoinConfiguration
controlPlane:
  localAPIEndpoint:
    bindPort: ${lb_port}
discovery:
  bootstrapToken:
    token: "${kubeadm_token}"
    apiServerEndpoint: "${lb_addr}:${lb_port}"
    unsafeSkipCAVerification: true
nodeRegistration:
  criSocket: "unix:///run/containerd/containerd.sock"
EOF
)

KUBEADM_WORKER_CONFIG_V1BETA1=$(cat <<-EOF
---
apiVersion: kubeadm.k8s.io/v1beta1
kind: JoinConfiguration
discovery:
  bootstrapToken:
    token: "${kubeadm_token}"
    apiServerEndpoint: "${lb_addr}:${lb_port}"
    unsafeSkipCAVerification: true
nodeRegistration:
  criSocket: "unix:///run/containerd/containerd.sock"
EOF
)

KUBEADM_CONFIG_V1BETA1=$(cat <<-EOF
---
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: "v${k8s_version}"
networking:
  dnsDomain: cluster.local
  podSubnet: "${cluster_cidr}"
controlPlaneEndpoint: "${lb_addr}:${lb_port}"
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: cgroupfs
EOF
)

# For v1beta2 version
KUBEADM_PRIMARY_CP_CONFIG_V1BETA2=$(cat <<-EOF
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
localAPIEndpoint:
  bindPort: ${lb_port}
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: "${kubeadm_token}"
  ttl: 2h0m0s
  usages:
  - signing
  - authentication
nodeRegistration:
  criSocket: "unix:///run/containerd/containerd.sock"
EOF
)

KUBEADM_SECONDARY_CP_CONFIG_V1BETA2=$(cat <<-EOF
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: JoinConfiguration
controlPlane:
  localAPIEndpoint:
    bindPort: ${lb_port}
discovery:
  bootstrapToken:
    token: "${kubeadm_token}"
    apiServerEndpoint: "${lb_addr}:${lb_port}"
    unsafeSkipCAVerification: true
nodeRegistration:
  criSocket: "unix:///run/containerd/containerd.sock"

EOF
)

KUBEADM_WORKER_CONFIG_V1BETA2=$(cat <<-EOF
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: JoinConfiguration
discovery:
  bootstrapToken:
    token: "${kubeadm_token}"
    apiServerEndpoint: "${lb_addr}:${lb_port}"
    unsafeSkipCAVerification: true
nodeRegistration:
  criSocket: "unix:///run/containerd/containerd.sock"
EOF
)

KUBEADM_CONFIG_V1BETA2=$(cat <<-EOF
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: "v${k8s_version}"
networking:
  dnsDomain: cluster.local
  podSubnet: "${cluster_cidr}"
controlPlaneEndpoint: "${lb_addr}:${lb_port}"
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: cgroupfs
EOF
)

case $K8S_MINOR_VERSION in
  "1.13"|"1.14")
    cat <<< $KUBEADM_CONFIG_V1BETA1 > config.yaml
    %{ if controlplane }
    %{ if primary_controlplane }
    cat <<< $KUBEADM_PRIMARY_CP_CONFIG_V1BETA1 >> config.yaml
    %{ else }
    cat <<< $KUBEADM_SECONDARY_CP_CONFIG_V1BETA1 >> config.yaml
    %{ endif }
    %{ else }
    cat <<< $KUBEADM_WORKER_CONFIG_V1BETA1 >> config.yaml
    %{ endif }
  ;;
  "1.15"|"1.16"|"1.17"|"1.18"|"1.19"|"1.20")
    cat <<< $KUBEADM_CONFIG_V1BETA2 > config.yaml
    %{ if controlplane }
    %{ if primary_controlplane }
    cat <<< $KUBEADM_PRIMARY_CP_CONFIG_V1BETA2 >> config.yaml
    %{ else }
    cat <<< $KUBEADM_SECONDARY_CP_CONFIG_V1BETA2 >> config.yaml
    %{ endif }
    %{ else }
    cat <<< $KUBEADM_WORKER_CONFIG_V1BETA2 >> config.yaml
    %{ endif }
  ;;
  "*")
  echo "Unsupported kubernetes version: $K8S_MINOR_VERSION"
  ;;
esac


download_to_file kubectl "https://storage.googleapis.com/kubernetes-release/release/v${k8s_version}/bin/linux/amd64/kubectl"
download_to_file kubeadm "https://storage.googleapis.com/kubernetes-release/release/v${k8s_version}/bin/linux/amd64/kubeadm"
download_to_file kubelet "https://storage.googleapis.com/kubernetes-release/release/v${k8s_version}/bin/linux/amd64/kubelet"
download_to_file crictl.tar.gz "https://github.com/kubernetes-sigs/cri-tools/releases/download/v$${CRITOOLS_VERSION}/crictl-v$${CRITOOLS_VERSION}-linux-amd64.tar.gz"
download_to_file cni-plugins.tar.gz "https://github.com/containernetworking/plugins/releases/download/$${CNI_VERSION}/cni-plugins-linux-amd64-$${CNI_VERSION}.tgz"
download_to_file node-health "https://github.com/gruntwork-io/health-checker/releases/download/v0.0.5/health-checker_linux_amd64"

mkdir -p "$${BIN_DIR}"
mkdir -p /opt/cni/bin

tar -C "$${BIN_DIR}" -xzf crictl.tar.gz
tar -C /opt/cni/bin -xzf cni-plugins.tar.gz

chmod +x {kubeadm,kubelet,kubectl,node-health}
cp kubeadm kubectl kubelet node-health $${BIN_DIR}

# Configure containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

systemctl restart containerd

# Configure Kubelet
# Based on - https://github.com/kubernetes/release/blob/v0.6.0/cmd/kubepkg/templates/latest/deb/kubelet/lib/systemd/system/kubelet.service
mkdir -p /etc/systemd/system/kubelet.service.d
cat <<EOF | tee /etc/systemd/system/kubelet.service
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=https://kubernetes.io/docs/
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=$${BIN_DIR}/kubelet
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Based on - https://github.com/kubernetes/release/blob/v0.6.0/cmd/kubepkg/templates/latest/deb/kubeadm/10-kubeadm.conf
cat <<EOF | tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart=$${BIN_DIR}/kubelet \$KUBELET_KUBECONFIG_ARGS \$KUBELET_CONFIG_ARGS \$KUBELET_KUBEADM_ARGS \$KUBELET_EXTRA_ARGS
EOF

cat <<EOF | tee /etc/systemd/system/node-health-responder.service
[Unit]
Description=kubelet: The Kubernetes Node health responder
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=$${BIN_DIR}/node-health --listener "0.0.0.0:8558" --port ${lb_port}
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl enable --now kubelet
systemctl enable --now node-health-responder

echo "Setting up kubeadm on the node"

%{ if primary_controlplane }
echo "Running kubeadm required atomic phases for configs"
echo "Preflight"
kubeadm init phase preflight --config config.yaml

echo "Kubelet generate certs"
kubeadm init phase certs all --config config.yaml

echo "Generating kubeconfig"
kubeadm init phase kubeconfig all --config config.yaml

# Upload the certs created to the cloud storage configured for
# the cluster.
gsutil -h "Content-Type:text/plain" cp -r /etc/kubernetes/pki ${cluster_bucket}
gsutil -h "Content-Type:text/plain" cp /etc/kubernetes/admin.conf ${cluster_bucket}

kubeadm init --config config.yaml
%{ else }
# For all non primary controlplane instances we wait for the connection
# to the apiserver address succeed.
i=0
while [[ $i -lt 13 ]]
do
  echo "Try count: $i"
  if [[ $i -eq 12 ]]; then
    echo "Retry count reached 12 apiserver address not ready, exitting"
    exit 1
  fi
  if curl -k -m 10 "https://${lb_addr}:${lb_port}/readyz" >/dev/null 2>&1;
  then
      echo "Connection to apiserver address succeeded"
      break
  fi

  sleep 5
  ((i++))
done

%{ if controlplane }
mkdir -p /etc/kubernetes/pki/etcd
gsutil cp ${cluster_bucket}/pki/ca.crt /etc/kubernetes/pki/
gsutil cp ${cluster_bucket}/pki/ca.key /etc/kubernetes/pki/
gsutil cp ${cluster_bucket}/pki/sa.pub /etc/kubernetes/pki/
gsutil cp ${cluster_bucket}/pki/sa.key /etc/kubernetes/pki/
gsutil cp ${cluster_bucket}/pki/front-proxy-ca.crt /etc/kubernetes/pki/
gsutil cp ${cluster_bucket}/pki/front-proxy-ca.key /etc/kubernetes/pki/
gsutil cp ${cluster_bucket}/pki/etcd/ca.crt /etc/kubernetes/pki/etcd/
gsutil cp ${cluster_bucket}/pki/etcd/ca.key /etc/kubernetes/pki/etcd/
%{ endif }

kubeadm join --config config.yaml
%{ endif }

echo "Kubernetes node configured successfully."
