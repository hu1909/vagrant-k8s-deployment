#!/bin/bash

set -euxo pipefail

KUBERNETES_VERSION=v1.32
CRIO_VERSION=v1.32

# set hostname
# sudo hostnamectl set-hostname controlplane

# echo "127.0.0.1 controlplane" | sudo tee -a /etc/hosts

# Set DNS server
cat <<EOF | sudo tee /etc/resolv.conf
 nameserver 8.8.8.8
 nameserver 8.8.4.4
EOF

sudo systemctl restart systemd-resolved

# disable the swap
sudo swapoff -a

sudo apt-get update

# Network configuration

# Create the .conf file to load the modules at bootup
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

if [ -f /etc/sysctl.d/k8s.conf ]; then
  echo "The file k8s.conf is good"
else
  echo "Please check the k8s.conf file"
  exit 1
fi

sudo sysctl --system

# Install Container Runtime

sudo apt-get update
sudo apt-get install software-properties-common curl apt-transport-https ca-certificates gpg -y
sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/prerelease:/main/deb/Release.key |
  gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/prerelease:/main/deb/ /" |
  tee /etc/apt/sources.list.d/cri-o.list

  
sudo apt-get update
sudo apt-get install cri-o -y

if [ $? -eq 0 ]; then
  echo "CRI-O has been installed successfully"
else
  echo "Please check the installation within CRI-O"
  exit 1
fi

sudo systemctl daemon-reload
sudo systemctl enable crio --now
sudo systemctl start crio.service
