#!/bin/bash
# setup antrea
kubectl apply -f https://github.com/antrea-io/antrea/releases/download/v1.5.0/antrea.yml

# setup metallb
#Install LoadBalancer MetalB
kubectl create ns metallb-system
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12/manifests/metallb.yaml -n metallb-system
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
touch /nappinstall/metallb-configmap.yaml
printf \
'apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - {{VIP}}' \
| tee -a /nappinstall/metallb-configmap.yaml
kubectl apply -f /nappinstall/metallb-configmap.yaml

