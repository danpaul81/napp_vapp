#!/bin/bash

export dockerregistry='projects.registry.vmware.com/nsx_application_platform/clustering'
export helmrepo='https://projects.registry.vmware.com/chartrepo/nsx_application_platform'

export tools="/nappinstall/kubernetes-tools-1.20.11-00_3.5.4-1.tar.gz"
export nappversion="3.2.0-0.0-19067744"


echo -e "\e[92mNSX MGR: Set container registry\e[37m"
curl -k -u ''{{nsxuser}}':'{{nsxpasswd}}'' -X PUT -H "Content-Type: application/json" -d '{"docker_registry":"'$dockerregistry'","helm_repo":"'$helmrepo'"}' https://{{nsxmanager}}/policy/api/v1/infra/sites/default/napp/deployment/registry

echo -e "\e[92mNSX MGR: push kubeconfig\e[37m"
curl -k -u ''{{nsxuser}}':'{{nsxpasswd}}'' -H 'Accept:application/json' -F 'file=@/root/.kube/config' https://{{nsxmanager}}/policy/api/v1/infra/sites/default/napp/deployment/kubeconfig

echo -e "\e[92mNSX MGR: kubetools\e[37m"
curl -k -u ''{{nsxuser}}':'{{nsxpasswd}}'' -H 'Accept:application/json' -F 'file=@'$tools'' https://{{nsxmanager}}/policy/api/v1/infra/sites/default/napp/deployment/tools/upload

echo -e "\e[92mNSX MGR: set NAPP settings\e[37m"
curl -k -u ''{{nsxuser}}':'{{nsxpasswd}}'' -X PATCH -H "Content-Type: application/json" -d '{"version":"'$nappversion'","storage_class":"nfs-client","form_factor": "evaluation","service_config":{"service_name":"'{{nappfqdn}}'"}}' https://{{nsxmanager}}/policy/api/v1/infra/sites/default/napp/deployment/platform

echo -e "\e[92mNSX MGR: wait 30s for NSX MGR cluster to sync\e[37m"
sleep 30s

echo -e "\e[92mNSX MGR: run pre-checks\e[37m"
curl -k -u ''{{nsxuser}}':'{{nsxpasswd}}'' -X PUT -H "Content-Type: application/json" -d '{"action":"PRE_CHECKS"}' https://{{nsxmanager}}/policy/api/v1/infra/sites/default/napp/deployment/platform/checks

echo -e "\e[92mNSX MGR: wait 10sec\e[37m"
sleep 10s

echo -e "\e[92mNSX MGR: check status\e[37m"
curl -k -u ''{{nsxuser}}':'{{nsxpasswd}}'' https://{{nsxmanager}}/policy/api/v1/infra/sites/default/napp/deployment/platform/checks/status
#curl -k -u ''{{nsxuser}}':'{{nsxpasswd}}'' -X PATCH -H "Content-Type: application/json" -d '{"deployment_action":{"action":"DEPLOY"}}' https://{{nsxmanager}}/policy/api/v1/infra/sites/default/napp/deployment/platform
