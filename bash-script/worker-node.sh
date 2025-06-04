#!/bin/bash

set -euxo pipefail

KUBERNETES_VERSION=v1.32
CRIO_VERSION=v1.32

curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update 
# Install kubectl, kubeadm, and kubelet

sudo apt-get install kubelet kubeadm -y
sudo apt-mark hold kubelet kubeadm
sudo systemctl start kubelet
sudo systemctl enable --now kubelet

cd /vagrant-data-script
chmod +x join.sh 
sudo ./join.sh

