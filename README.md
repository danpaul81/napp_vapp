# VAPP / OVA Images including all infrastructure needed to deploy NSX 3.2 Application Platform
## Introduction 

This guide takes you through the process of deploying the NSX Application Platform. 
Depending on the infrastructure where you'll run NSX Application Platform we decided to have a vAPP with all VMs inside for vCenter and a second solution for vCLoud Director (vCD) deployment. 

This release is for evaluation only, but later we may add some features to make it production ready.

![alt text](https://github.com/danpaul81/napp_vapp/blob/main/images/architecture.jpg?raw=true)

The vAPP will deploy the Blue boxes on the right side and they can be in the same network like DNS and NSX Manager, but they can also be in a different Network like in the picture above. 
The PodNetwork must have at least one /24 Network for each VM (master and node). So in our case we could also use as PodNet 172.25.0.0/23 because we have one Master and one Node. 
The Load Balancer IPs (VIP Pool) must be within the same subnet where master and node are connected. 


# VAPP / OVA Images to deploy NSX 3.2 Application Platform. See internal MS Teams Documentation
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
