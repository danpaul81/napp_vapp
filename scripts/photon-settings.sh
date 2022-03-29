#!/bin/bash -eux

##
## Misc configuration
##

echo '> Disable IPv6'
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf

echo '> Enable Docker Daemon'
systemctl enable docker
echo '> Start Docker'
systemctl start docker

#disable cloud init as VCD tries to exec it
systemctl disable cloud-init.service
systemctl disable iptables

#disable vmtools guest customization as VCD tries to exec it
/usr/bin/vmware-toolbox-cmd config set deployPkg enable-customization false

#echo '> Loading Docker Images'
#docker pull harbor-repo.vmware.com/dpaul/idsreplay:latest
#docker tag harbor-repo.vmware.com/dpaul/idsreplay:latest idsreplay
#docker pull harbor-repo.vmware.com/dpaul/nsx-demo
#docker tag harbor-repo.vmware.com/dpaul/nsx-demo nsx-demo

#echo '> Applying latest Updates...'
tdnf -y update || true

echo '> Installing Additional Packages...'
tdnf install -y \
  logrotate \
  wget \
  unzip \
  tar \
  sshpass \
  nfs-utils \
  docker-19.03.10-3.ph4 \
  kubernetes-kubeadm-1.19.7-1.ph4

echo '> Done'
