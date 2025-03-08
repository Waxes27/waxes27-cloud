# Update the package list and install necessary packages
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system


apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gpg \
    sudo \
    software-properties-common \
    containerd \
    && sudo apt-get clean

# Add the Kubernetes GPG key for version 1.24
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update

# Install kubeadm, kubelet, and kubectl
sudo apt-get install -y \
    kubeadm \
    kubelet \
    kubectl \
    && sudo apt-get clean

# Hold Kubernetes packages at the specified version to prevent updates
sudo apt-mark hold kubeadm kubelet kubectl

# Install Docker (necessary for Kubernetes node containers)
sudo apt-get update && sudo apt-get install -y docker.io

# kubeadm init --pod-network-cidr=192.168.0.0/16 && tail -f /dev/null