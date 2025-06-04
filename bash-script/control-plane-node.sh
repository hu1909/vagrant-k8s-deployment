#!/bin/bash

set -euxo pipefail

KUBERNETES_VERSION=v1.32
CRIO_VERSION=v1.32

curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update 
# Install kubectl, kubeadm, and kubelet

sudo apt-get install kubelet kubeadm kubectl -y
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl start kubelet
sudo systemctl enable --now kubelet

# Config the control-plane node

sudo kubeadm config images pull
sudo kubeadm init --config=/vagrant-data-script/config_kubeadm.yaml

if [ $? -eq 0 ]; then
  echo "The control-plane node has been configured successfully"
  kubeadm token create --print-join-command >> /vagrant-data-script/join.sh
else
  echo "Please check the kubeadm init"
  exit 1
fi

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

mkdir -p /home/vagrant/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown $(id -u):$(id -g) /home/vagrant/.kube/config

# Install addon Network plugin
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.28.3/manifests/calico.yaml
kubectl apply -f calico.yaml 
