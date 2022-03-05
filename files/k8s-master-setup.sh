#!/bin/bash

#The Script create a Kubeadm Config, install Kubernetes and store the results in the File kubeadm-init.out

mkdir /root/kubeadm
touch /rootkubeadm/kubeadm-config.yaml
printf \
'apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: {{K8SVERSION}}
controlPlaneEndpoint: "{{K8SMASTER}}:6443"
networking:
  podSubnet: {{PODNET}}' \
| tee -a /root/kubeadm/kubeadm-config.yaml

sudo kubeadm init --config=/root/kubeadm/kubeadm-config.yaml --upload-certs | tee /root/kubeadm/kubeadm-init.out

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
source /usr/share/bash-completion/bash_completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
