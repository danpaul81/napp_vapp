#!/bin/bash

#The Script create a Kubeadm Config, install Kubernetes and store the results in the File kubeadm-init.out

mkdir -p /root/kubeadm
touch /root/kubeadm/kubeadm-config.yaml
printf \
'apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: {{K8SVERSION}}
controlPlaneEndpoint: "{{K8SMASTER}}:6443"
networking:
  podSubnet: {{PODNET}}' \
| tee -a /root/kubeadm/kubeadm-config.yaml

kubeadm init --config=/root/kubeadm/kubeadm-config.yaml --upload-certs | tee /root/kubeadm/kubeadm-init.out

export KUBECONFIG=/root/.kube/config

mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config
chown $(id -u):$(id -g) /root/.kube/config
source /usr/share/bash-completion/bash_completion
echo 'source <(kubectl completion bash)' >>/root/.bashrc
