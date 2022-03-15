#!/bin/bash

#The Script create a Kubeadm Config, install Kubernetes and store the results in the File kubeadm-init.out

touch /nappinstall/kubeadm-config.yaml
printf \
'apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: {{K8SVERSION}}
controlPlaneEndpoint: "{{K8SMASTER}}:6443"
networking:
  podSubnet: {{PODNET}}' \
| tee -a /nappinstall/kubeadm-config.yaml

kubeadm init --config=/nappinstall/kubeadm-config.yaml --upload-certs | tee /nappinstall/kubeadm-init.out
