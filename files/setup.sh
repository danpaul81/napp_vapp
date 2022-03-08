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

    echo -e "\e[92mConfiguring Static IP Address ..." > /dev/console
    cat > /etc/systemd/network/${NETWORK_CONFIG_FILE} << __CUSTOMIZE_PHOTON__
[Match]
Name=e*

[Network]
Address=${IP_ADDRESS}/${NETMASK}
Gateway=${GATEWAY}
DNS=${DNS_SERVER}
Domain=${DNS_DOMAIN}
__CUSTOMIZE_PHOTON__

    echo -e "\e[92mRestarting Network ..." > /dev/console
    systemctl restart systemd-networkd

    echo -e "\e[92mConfiguring root password ..." > /dev/console
    ROOT_PASSWORD=$(echo "${ROOT_PASSWORD_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
	
    if [ -z "${ROOT_PASSWORD}" ]; then
	echo "Empty password setting. No Change"
    else
        echo "root:${ROOT_PASSWORD}" | /usr/sbin/chpasswd
    fi

# depending on appliance role (master or node) prepare vm

    if [ ${ROLE} == "node" ]; then
	# preparation of node -> will also setup master
	export SSHPASS=${ROOT_PASSWORD}
	
	# create SSH Passphrase. Host Key checking is already disabled
	ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N ""
	sshpass -e ssh-copy-id -i /root/.ssh/id_rsa ${MASTER_IP_ADDRESS}

	mkdir -p /nappinstall
	
	#echo "export nsxmanager=${NSXMGR}" > /nappinstall/variables.txt
	#echo "export nsxuser=${NSXUSER}" >> /nappinstall/variables.txt
	#echo "export nsxpasswd='${NSXPASSWORD}'" >> /nappinstall/variables.txt 
	#echo "export ippool=${VIP}" >> /nappinstall/variables.txt 

        #prepare data disk sdb1. only necessary on node
	echo "Creating Data Disk"
	echo 'type=83' | sfdisk /dev/sdb
	mkfs.ext4 /dev/sdb1
	mkdir -p /nfs
	mount /dev/sdb1 /nfs
	echo '/dev/sdb1       /nfs    ext4    defaults     0   0' | sudo tee -a /etc/fstab

	# re-mount docker / kubelet datadir to data disk
	echo "re-mount Docker / Kubelet storage"
	docker rm -f $(docker ps -aq); docker rmi -f $(docker images -q)
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

	echo "Creating NFS SERVER"
	mkdir -p /nfs/k8s
	echo '/nfs/k8s        *(rw,sync,no_root_squash,no_subtree_check)' | tee -a /etc/exports
	chown nobody:nogroup /nfs/k8s
	systemctl enable nfs-server.service	
	systemctl start nfs-server.service

	# SETUP K8S Master
	cp /root/k8s-master-setup.sh /nappinstall

	K8SVERSION=$(rpm -q kubernetes-kubeadm |cut -d'-' -f3)
	sed -i -e 's\{{K8SVERSION}}\'$K8SVERSION'\g' /nappinstall/k8s-master-setup.sh
	sed -i -e 's\{{K8SMASTER}}\'$MASTER_IP_ADDRESS'\g' /nappinstall/k8s-master-setup.sh
	sed -i -e 's\{{PODNET}}\'$PODNET'\g' /nappinstall/k8s-master-setup.sh
	
	# copy customized k8s master setup script & execute
	scp /nappinstall/k8s-master-setup.sh ${MASTER_IP_ADDRESS}:/nappinstall
	ssh ${MASTER_IP_ADDRESS} bash /nappinstall/k8s-master-setup.sh
        	
	# Join K8S Cluster
	ssh ${MASTER_IP_ADDRESS} tail -n 2 /root/kubeadm/kubeadm-init.out > /nappinstall/kubeadm-node.sh
	bash /nappinstall/kubeadm-node.sh

  
        #preload container images
	if [ ${PRELOAD} == "True" ]; then
	  echo "preloading container images"
	fi

	# install Antrea
	ssh ${MASTER_IP_ADDRESS} kubectl apply -f https://github.com/antrea-io/antrea/releases/download/v1.5.0/antrea.yml 


    else
	# preparation of master node
	mkdir /nappinstall
    fi


    # Ensure we don't run customization again
    touch /root/ran_customization
fi
