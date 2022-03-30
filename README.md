# VAPP / OVA Images including all infrastructure needed to deploy NSX 3.2 Application Platform

## This documentation is not yet finished. please refer to existing internal word doc
## Introduction 

This guide takes you through the process of deploying the NSX Application Platform. 
Depending on the infrastructure where you'll run NSX Application Platform we decided to have a vAPP with all VMs inside for vCenter and a second solution for vCLoud Director (vCD) deployment. 

This release is for evaluation only, but later we may add some features to make it production ready.

![alt text](https://github.com/danpaul81/napp_vapp/blob/main/images/architecture.png?raw=true)

The vAPP will deploy the Blue boxes on the right side and they can be in the same network like DNS and NSX Manager, but they can also be in a different Network like in the picture above. 
The PodNetwork must have at least one /24 Network for each VM (master and node). So in our case we could also use as PodNet 172.25.0.0/23 because we have one Master and one Node. 
The Load Balancer IPs (VIP Pool) must be within the same subnet where master and node are connected. 

## Prerequisites 

Folowing prerequisites are needed 

* NSX Manager 3.2 

* DNS Server 

Access to NSX Application Platform requires an exposed service from the kubernetes cluster. IP will be chosen from the Load Balancer Pool and a DNS Entry must exist BEFORE the deployment because NSX will ask the DNS Server which IP should be used for the Service. 

In the picture above we create a LoadBalancer Pool with the IP addresses from 172.16.10.200-172.16.20.205. If we create a DNS entry like “napp.corp.local” we must point to one of the defined Addresses. (napp.corp.local=172.16.10.202). While the setupprocess NSX Manager will ask the DNS Server what IP Address is used for “napp.corp.local” and will create the Service IP in the K8S Cluster.  

Worst Case Workaround: If there is no chance to create an DNS entry on the DNS Server for the NSX Application Platform, you must connect to the NSX Manager CLI via root and create an Host entry in the /etc/hosts.  

* 68 Gigabyte RAM (4G Master Node / 64G Worker Node) 

* 1 Terabyte Disk Drive 

vSphere DRS must be enabled in the Cluster where you want to deply NAPP even if you have only one host in the cluster. Otherwhise you get the following deployment Error 

![alt text](https://github.com/danpaul81/napp_vapp/blob/main/images/drs_error.png?raw=true)

* NAPP_VAPP can be deployed in a VLAN based DVPG or NSX VLAN/Overlay Segment. Default Gateway, DNS must work and internet connection must be possible.  

## Setup NSX vAPP in vCenter 

After you have downloaded the vAPP OVA from [releases] (https://github.com/danpaul81/napp_vapp/releases/) 

### Install vAPP 

Like with all other vAPPS you need to select the Template, Folder, Compute Resource, Storage and the belonging Network. 
Customize Template is the important part. Change the settings to your environment. Please check the picture above if you need to understand which IP is used where.

![alt text](https://github.com/danpaul81/napp_vapp/blob/main/images/customize_ip.png?raw=true)

We recognized some Issues while deploying if the Internet Connection is slow. So you can decide to load alle Images upfront to the Node - the checkbox is enabled by default. Be aware it could take a couple of hours before you see something happen in NSX. You can also choose to start the NSX Application deployment fully automated. 

![alt text](https://github.com/danpaul81/napp_vapp/blob/main/images/customize_preload.png?raw=true)

In adittion we improved the deployment time with a local cache option. We loaded all Files on a Server in the OneCloud and if you insert an IP in the new Field Localcache IP the Nodes will try to download there the images first before they trey to download from the public Harbor registry.
### The IP is: 10.124.48.62

![alt text](https://github.com/danpaul81/napp_vapp/blob/main/images/localcache.png?raw=true)

### Start vAPP 

Just start the overall vapp – both VMs will do their own setup steps in parallel. Depending on speed of your internet connection this can take some hours! 

### Watching the Process 

All steps will be printed on the console from the Master and the Node and you can check the process there. 
The Logfiles will be stored in /var/log/photon-customization.log 
You can also SSH into the Master or the Node using root/the password you created while deployment and check if Kubernetes is up and running. 

```
(watch) kubectl get pods -A 
```
![alt text](https://github.com/danpaul81/napp_vapp/blob/main/images/kubectl.png?raw=true)

You should see after some Minutes all machines in Ready state. When all Images are downloaded the next steps can be seen in NSX Manager and also with the kubectl command. 
If all Images for the Base Installation are downloaded (Last Image is zookeeper), the script will automatically push the .kube/config to NSX Manager and make all settings that are needed to proceed. 

![alt text](https://github.com/danpaul81/napp_vapp/blob/main/images/nsx_deployment.png?raw=true)

If the Installation will not start after 2 minutes you can start the Installation also manually. 
If everything works as expected, the certmanager will be installed 

![alt text](https://github.com/danpaul81/napp_vapp/blob/main/images/certmgr.png?raw=true)

Followed by Project Contour 

![alt text](https://github.com/danpaul81/napp_vapp/blob/main/images/contourcontainer.png?raw=true)

And than the NSXi Platform will be installed in some steps

![alt text](https://github.com/danpaul81/napp_vapp/blob/main/images/nsxi-platform.png?raw=true)

![alt text](https://github.com/danpaul81/napp_vapp/blob/main/images/nsx_gui_deployment.png?raw=true)

If the Installation fails, it is most likely that the Metrics Postgresql Cluster does not come up.

![alt text](https://github.com/danpaul81/napp_vapp/blob/main/images/metrics-postcrash.png?raw=true)

You should press the Retry  Buttun in NSX Manager and if it is still not working retry it 2 or 3 times.

![alt text](https://github.com/danpaul81/napp_vapp/blob/main/images/retrydeployment.png?raw=true)

If this does not help you should check if you can deploy the vAPP in a more performant environment. If the Environment is nested it will also fail and you should proceed with the Single VMs vAPP for vCLOUD Director.

## Setup NSX vAPP in vCLoud Director aka OneCloud
To deploy in vCloud director import  NAPP_Appliance_*_master_app.ova and NAPP_Appliance_*_node_app.ova each as separate vAPP. 
The actual release and MD5 hashes can be found here: (https://github.com/danpaul81/napp_vapp/releases/)

Both need to be deployed with identical options except the “role”. This must be set “master” for master VM and “node” for node VM. 
Within the settings of each newly deployed VM disable Guest OS Customization and then move the VM into you vAPP. In network settings choose fitting network and IP Mode DHCP. 
After moving VMs into your existing vAPP you can delete the two newly created VAPPS.
Then just start both VMs (startup order doesn’t matter) 

## Troubleshooting

### Initial VAPP Deployment Failure
If initial deployment of VAPP failes with error message in VM console you need to re-deploy the vapp. Re-starting vapp during setup process or after failes setup process will result in inconsistent state. This might be fixed in future release.  
Initial setup was successful when file “/root/ran_customization” exists. Then rebooting of appliance is safe.

### Cert-Manager Error (One Cloud related)
If the Setup will fail in the first phase (Cert Manager installation) you may see this error Message in the NSX Manager.

![alt text](https://github.com/danpaul81/napp_vapp/blob/main/images/certmanager.png?raw=true)

In this case a retry will not fix the Problem and you will run in other Problems while installing contour.

![alt text](https://github.com/danpaul81/napp_vapp/raw/main/images/contour.png?raw=true)

The only option to fix this, is to cancel the Installation in NSX Manager run the Cleanup (if needed) and install NAPP via the NSX Manager UI again. 
If it does not work and it will fail again you need to try it again to a different Time of the Day. 
It seems that the Problem comes from our shared Storage in OneCloud and if to many people accessing the Storage the latency becomes to high and the Certmanager will not comes up in the right time. This means that all other Container will not get the needed Certs and will fail also.

### DNS Error
If your DNS Entry for the NAPP Appliance cannot be find you will get an error message like this and you need to correct the DNS entry.

![alt text](https://github.com/danpaul81/napp_vapp/blob/main/images/dnserror1.png?raw=true)

If the IP Address for the DNS Entry is not included in the list of VIP Addresses you provided to Metallb Loadbalancer you will get the following Errormessage and you should correct the DNS Entry to an address in the IP Space of the VIP Addresses.

![alt text](https://github.com/danpaul81/napp_vapp/blob/main/images/dnserror2.png?raw=true)

You can check it also on the CLI with the command:
kubectl get svc -n projectcontour
You will see the EXTERNAL-IP is in pending

![alt text](https://github.com/danpaul81/napp_vapp/blob/main/images/checkserviceip.png?raw=true)

### Cleanup
Normally you can delete the NSX Application Platfrom via the NSX Manager. In some cases and especially if something went wrong in the beginning it could be that the deletion process will not clean up the Kubernetes Cluster and you will not be able to redeploy NAPP if the Namespaces “cert-manager”, nsxi-platform” and “projectcountour” exist. First you should try to delete the namespaces with the command:
kubectl delete namespaces cert-manager nsxi-platform projectcontour
If this fails and namespace stucks in state “Terminating” you should check the cluster APIService
kubectl get APIService 
You may find there entries for projectcontour or nsxi-platform that should be deleted.

![alt text](https://github.com/danpaul81/napp_vapp/blob/main/images/apiservices.png?raw=true)
  
kubectl delete APIService v1beta1.metrics.k8s.io v1alpha1.projectcontour.io

## VAPP / OVA Images to deploy NSX 3.2 Application Platform. See internal MS Teams Documentation
more documentation to be added here

### Image creation scripts based on Reference for building PhotonOS Virtual Appliance (OVA) using Packer

Based on William Lams Packer PhotonOS Appliance (https://github.com/lamw/photonos-appliance)

#### Requirements

* MacOS or Linux Desktop
* vCenter Server 
* [VMware OVFTool](https://www.vmware.com/support/developer/ovf/)
* [Packer](https://www.packer.io/intro/getting-started/install.html)
* [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.1)
* [PowerCli](https://developer.vmware.com/powercli)
* [xmlstarlet](http://xmlstar.sourceforge.net)


> `packer` builds the OVA on a remote ESXi host via the [`vsphere-iso`](https://www.packer.io/docs/builders/vsphere-iso.html) builder. 


`photon-builder.json` vCenter Server settings where build VM will be created
`photon-version.json` PhotonOS ISO Image / Source and VM Settings 
`photon.json` packer main config file
`photon-dev.json` identical to `photon.json` but additionally deploys newly created OVA appliance(s) to a vCenter Server

NAPP specific modifications are done in files/setup.sh

```
./build.sh
````

If you wish to automatically deploy the PhotonOS appliance after successfully building the OVA run `./build.sh dev` instead.
