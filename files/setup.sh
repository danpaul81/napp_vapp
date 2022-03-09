#!/bin/bash

# Bootstrap script

set -euo pipefail

if [ -e /root/ran_customization ]; then
    exit
else
    NETWORK_CONFIG_FILE=$(ls /etc/systemd/network | grep .network)

    DEBUG_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep -m1 "guestinfo.debug")
    DEBUG=$(echo "${DEBUG_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    LOG_FILE=/var/log/bootstrap.log
    if [ ${DEBUG} == "True" ]; then
        LOG_FILE=/var/log/photon-customization-debug.log
        set -x
        exec 2> ${LOG_FILE}
        echo
        echo "### WARNING -- DEBUG LOG CONTAINS ALL EXECUTED COMMANDS WHICH INCLUDES CREDENTIALS -- WARNING ###"
        echo "### WARNING --             PLEASE REMOVE CREDENTIALS BEFORE SHARING LOG            -- WARNING ###"
        echo
    fi

    MASTER_IP_ADDRESS_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep -m1 "guestinfo.master_ip")
    NODE_IP_ADDRESS_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep -m1 "guestinfo.node_ip")
    NETMASK_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep -m1 "guestinfo.netmask")
    VIP_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep -m1 "guestinfo.vip_pool")
    GATEWAY_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep -m1 "guestinfo.gateway")
    NTP_SERVER_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep -m1 "guestinfo.ntp")
    DNS_SERVER_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep -m1 "guestinfo.dns")
    DNS_DOMAIN_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep -m1 "guestinfo.domain")
    ROOT_PASSWORD_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep -m1 "guestinfo.root_password")
    ROLE_PROPERTY==$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep -m1 "guestinfo.role")
    NSXMGR_PROPERTY==$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep -m1 "guestinfo.nsxmanager")
    NSXUSER_PROPERTY==$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep -m1 "guestinfo.nsxuser")
    NSXPASSWORD_PROPERTY==$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep -m1 "guestinfo.nsxpassword")
    PODNET_PROPERTY==$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep -m1 "guestinfo.podnet")
    PRELOAD_PROPERTY==$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep -m1 "guestinfo.preload")
    NAPPFQDN_PROPERTY==$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep -m1 "guestinfo.nappfqdn")

    ROLE=$(echo "${ROLE_PROPERTY}" | cut -d'"' -f4)
    PRELOAD=$(echo "${PRELOAD_PROPERTY}" | cut -d'"' -f4)

    MASTER_IP_ADDRESS=$(echo "${MASTER_IP_ADDRESS_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    NODE_IP_ADDRESS=$(echo "${NODE_IP_ADDRESS_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')


    if [ ${ROLE} == "master" ]; then
        IP_ADDRESS=${MASTER_IP_ADDRESS}
	HOSTNAME="napp-k8s-master"
    else
        IP_ADDRESS=${NODE_IP_ADDRESS}	
	HOSTNAME="napp-k8s-node"
    fi

    echo "${NODE_IP_ADDRESS} napp-k8s-node" >> /etc/hosts
    echo "${MASTER_IP_ADDRESS} napp-k8s-master" >> /etc/hosts
    hostnamectl set-hostname ${HOSTNAME}

    NETMASK=$(echo "${NETMASK_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    GATEWAY=$(echo "${GATEWAY_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    DNS_SERVER=$(echo "${DNS_SERVER_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    DNS_DOMAIN=$(echo "${DNS_DOMAIN_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    NSXMGR=$(echo "${NSXMGR_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    NSXUSER=$(echo "${NSXUSER_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    NSXPASSWORD=$(echo "${NSXPASSWORD_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    VIP=$(echo "${VIP_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    PODNET=$(echo "${PODNET_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    NAPPFQDN=$(echo "${NAPPFQDN_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    NTP_SERVER=$(echo "${NTP_SERVER_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    echo -e "\e[92mConfiguring Static IP Address ...\e[37m"
    cat > /etc/systemd/network/${NETWORK_CONFIG_FILE} << __CUSTOMIZE_PHOTON__
[Match]
Name=e*

[Network]
Address=${IP_ADDRESS}/${NETMASK}
Gateway=${GATEWAY}
DNS=${DNS_SERVER}
Domain=${DNS_DOMAIN}
__CUSTOMIZE_PHOTON__

    echo -e "\e[92mRestarting Network ...\e[37m"
    systemctl restart systemd-networkd

    echo -e "\e[92mConfiguring root password ...\e[37m"
    ROOT_PASSWORD=$(echo "${ROOT_PASSWORD_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
	
    if [ -z "${ROOT_PASSWORD}" ]; then
	echo "Empty password setting. No Change"
    else
        echo "root:${ROOT_PASSWORD}" | /usr/sbin/chpasswd
    fi

    echo -e "\e[92mSetting up NTP\e[37m"
    echo "NTP=${NTP_SERVER}" >> /etc/systemd/timesyncd.conf
    systemctl restart systemd-timesyncd

# depending on appliance role (master or node) prepare vm

    if [ ${ROLE} == "node" ]; then
	# preparation of node -> will also setup master
	echo -e "\e[92m Role: k8s node\e[37m"
	export SSHPASS=${ROOT_PASSWORD}
	
	# create SSH Passphrase. Host Key checking is already disabled
	ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N ""
	sshpass -e ssh-copy-id -i /root/.ssh/id_rsa ${MASTER_IP_ADDRESS}
	
	tar -xzf /root/nappinstall.tgz -C /
	#mkdir -p /nappinstall
	
	#echo "export nsxmanager=${NSXMGR}" > /nappinstall/variables.txt
	#echo "export nsxuser=${NSXUSER}" >> /nappinstall/variables.txt
	#echo "export nsxpasswd='${NSXPASSWORD}'" >> /nappinstall/variables.txt 
	#echo "export ippool=${VIP}" >> /nappinstall/variables.txt 
	#echo "export ippool=${NAPPFQDN}" >> /nappinstall/variables.txt 

        #prepare data disk sdb1. only necessary on node
	echo -e "\e[92mCreating Data Disk\e[37m"
	echo 'type=83' | sfdisk /dev/sdb
	mkfs.ext4 /dev/sdb1
	mkdir -p /nfs
	mount /dev/sdb1 /nfs
	echo '/dev/sdb1       /nfs    ext4    defaults     0   0' | sudo tee -a /etc/fstab

	# re-mount docker / kubelet datadir to data disk
	echo -e "\e[92mre-mount Docker / Kubelet storage\e[37m"
	#docker rm -f $(docker ps -aq); docker rmi -f $(docker images -q)
	systemctl stop docker
	rm -rf /var/lib/docker
	rm -rf /var/lib/kubelet
	mkdir /var/lib/docker
	mkdir /var/lib/kubelet/
	mkdir /nfs/docker
	mkdir /nfs/kubelet
	mount --rbind /nfs/docker/ /var/lib/docker
	mount --rbind /nfs/kubelet/ /var/lib/kubelet
	systemctl start docker
	systemctl restart kubelet

	echo -e "\e[92mCreating NFS SERVER\e[37m"
	mkdir -p /nfs/k8s
	echo '/nfs/k8s        *(rw,sync,no_root_squash,no_subtree_check)' | tee -a /etc/exports
	chown nobody:nogroup /nfs/k8s
	systemctl enable nfs-server.service	
	systemctl start nfs-server.service

	echo -e "\e[92mprepare k8s master node script\e[37m"

	K8SVERSION=$(rpm -q kubernetes-kubeadm |cut -d'-' -f3)
	sed -i -e 's\{{K8SVERSION}}\'$K8SVERSION'\g' /nappinstall/k8s-master-setup.sh
	sed -i -e 's\{{K8SMASTER}}\'$MASTER_IP_ADDRESS'\g' /nappinstall/k8s-master-setup.sh
	sed -i -e 's\{{PODNET}}\'$PODNET'\g' /nappinstall/k8s-master-setup.sh
	
	echo -e "\e[92mcopy customized k8s master setup script to master & create cluster\e[37m"
	scp /nappinstall/k8s-master-setup.sh ${MASTER_IP_ADDRESS}:/nappinstall
	ssh ${MASTER_IP_ADDRESS} bash /nappinstall/k8s-master-setup.sh
        	
	echo -e "\e[92mJoin K8S Cluster\e[37m"
	ssh ${MASTER_IP_ADDRESS} tail -n 2 /root/kubeadm/kubeadm-init.out > /nappinstall/kubeadm-node.sh
	bash /nappinstall/kubeadm-node.sh

	echo -e "\e[92mgrant local node api access\e[37m"
	mkdir -p /root/.kube
	scp ${MASTER_IP_ADDRESS}:/etc/kubernetes/admin.conf /root/.kube/config
 	chown $(id -u):$(id -g) /root/.kube/config
	export KUBECONFIG=/root/.kube/config

        if [ ${PRELOAD} == "True" ]; then
          echo -e "\e[92mpreloading NSX container base images\e[37m"
          docker pull projects.registry.vmware.com/antrea/antrea-ubuntu:v1.5.0
	  docker pull quay.io/metallb/controller:main
	  docker pull quay.io/metallb/speaker:main
        else
	  echo -e "\e[92mpreloading NSX container base images\e[37m"
	fi

	# push VIP to metallb configmap
        sed -i -e 's\{{VIP}}\'$VIP'\g' /nappinstall/metallb-configmap.yaml

	# push NFS Server IP to nfs-provisioner.yaml
	sed -i -e 's\{{NFSSERVER}}\'$NODE_IP_ADDRESS'\g' /nappinstall/nfs-provisioner.yaml

	# install Antrea/MetalLB/NFS Provisioner
	echo -e "\e[92mSetting Up k8s services Antrea, MetalLB and NFS-Client-Provisioner\e[37m"

	# setup antrea
	kubectl apply -f https://github.com/antrea-io/antrea/releases/download/v1.5.0/antrea.yml
	# setup metallb
	kubectl create ns metallb-system
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/main/manifests/metallb.yaml -n metallb-system
	kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
	kubectl apply -f /nappinstall/metallb-configmap.yaml

	# nfs-provisioner
	kubectl apply -f /nappinstall/nfs-provisioner.yaml

        #preload container base images
	if [ ${PRELOAD} == "True" ]; then
	  echo -e "\e[92mpreloading NSX container base images\e[37m"
	  bash /nappinstall/download-base-images.sh
	else
	  echo -e "\e[92mno NSX container preload for base images selected\e[37m"
	fi

	echo -e "\e[92mPreparing NSX Manager NAPP Settings\e[37m"
        sed -i -e 's\{{nsxuser}}\'$NSXUSER'\g' /nappinstall/napp-install-nsx.sh
        sed -i -e 's\{{nsxpasswd}}\'$NSXPASSWORD'\g' /nappinstall/napp-install-nsx.sh
        sed -i -e 's\{{nsxmanager}}\'$NSXMGR'\g' /nappinstall/napp-install-nsx.sh
        sed -i -e 's\{{nappfqdn}}\'$NAPPFQDN'\g' /nappinstall/napp-install-nsx.sh

        #preload container base images
	if [ ${PRELOAD} == "True" ]; then
	  echo -e "\e[92mpreloading NSX application platform container images\e[37m"
	  bash /nappinstall/download-solution-images.sh
	else
	  echo -e "\e[92mno NSX container preload for solution images selected\e[37m"
	fi

    else
	# preparation of master node
	mkdir /nappinstall
    fi


    # Ensure we don't run customization again
    touch /root/ran_customization
fi
