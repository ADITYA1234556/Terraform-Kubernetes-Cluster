#!/bin/bash
###KUBEMASTER###
export DEBIAN_FRONTEND=noninteractive
#System Settings
echo "overlay" | sudo tee /etc/modules-load.d/k8s.conf
echo "br_netfilter" | sudo tee -a /etc/modules-load.d/k8s.conf

sudo modprobe overlay
sudo modprobe br_netfilter

echo "net.bridge.bridge-nf-call-iptables = 1" | sudo tee -a /etc/sysctl.d/k8s.conf
echo "net.bridge.bridge-nf-call-ip6tables = 1" | sudo tee -a /etc/sysctl.d/k8s.conf
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.d/k8s.conf

sudo sysctl --system

lsmod | grep br_netfilter
lsmod | grep overlay

sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

#Installing CRI-O#

sudo apt-get update -y
sudo apt-get install -y software-properties-common curl apt-transport-https ca-certificates
sudo mkdir -p -m 755 /etc/apt/keyrings
sudo curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/prerelease:/main/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/prerelease:/main/deb/ /" | sudo tee /etc/apt/sources.list.d/cri-o.list

sudo apt-get update -y
sudo apt-get install -y cri-o

sudo systemctl daemon-reload
sudo systemctl enable crio --now
sudo systemctl start crio.service


#Installing Kubeadm, Kubelet & Kubectl#
KUBEVERSION=v1.30
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p -m 755 /etc/apt/keyrings
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet

# Identify role (Master or Worker) based on index from Terraform
ROLE=$(curl -s http://169.254.169.254/latest/meta-data/tags/instance/Name)

if [[ "$ROLE" == *"k8s-node-0"* ]]; then
  echo "Setting up Kubernetes Master Node..."

  # Initialize the Kubernetes cluster on the master node
  sudo kubeadm init --pod-network-cidr=10.244.0.0/16

  # Configure kubectl for the master node
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

  # Deploy a Pod network (e.g., Weave)
  kubectl apply -f https://reweave.azurewebsites.net/k8s/v1.29/net.yaml

  # Save join command
  mkdir -p /tmp/k8s
  kubeadm token create --print-join-command > /tmp/k8s/join-command.sh

  # Upload the join command to S3 (Replace with your bucket name)
  aws s3 cp /tmp/k8s/join-command.sh s3://111-aditya-bucket/join-command.sh

  echo "Master node setup complete. Join command uploaded to S3."
else
  echo "Setting up Kubernetes Worker Node..."

  # Download the join command from S3
  aws s3 cp s3://111-aditya-bucket/join-command.sh /tmp/join-command.sh
  chmod +x /tmp/join-command.sh

  # Execute the join command to join the worker node to the cluster
  sudo bash /tmp/join-command.sh

  echo "Worker node successfully joined the Kubernetes cluster."
fi