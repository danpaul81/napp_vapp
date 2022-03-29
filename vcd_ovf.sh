#!/bin/bash

#session ID on VCD
SESSIONID=54849df648114cdf98a9e20e20fc0ce8


#local path to ova sources
SOURCE_MASTER='output-vsphere-iso/NAPP_Appliance_0.1.3_master_app.ova'
SOURCE_NODE='output-vsphere-iso/NAPP_Appliance_0.1.3_node_app.ova'

#VCD URL/org/vdc/vapp
#important: select different VAPP names for master/node
TARGET_MASTER='vcloud://ams2-vcd01.oc.vmware.com/cloud?org=ams2-vcd01-emea-sddc-lt-labs-t&vdc=ams2-vcd01-emea-sddc-lt-labs-d-ovdc1&vapp=NAPP_MASTER'
TARGET_NODE='vcloud://ams2-vcd01.oc.vmware.com/cloud?org=ams2-vcd01-emea-sddc-lt-labs-t&vdc=ams2-vcd01-emea-sddc-lt-labs-d-ovdc1&vapp=NAPP_NODE'

#
#review and corect. dont use simple root password as deployment might fail
COMMONOPTS='--noSSLVerify --diskMode=thin 
--prop:guestinfo.master_ip=192.168.110.210  
--prop:guestinfo.node_ip=192.168.110.211
--prop:guestinfo.netmask=24 
--prop:guestinfo.gateway=192.168.110.1  
--prop:guestinfo.dns=192.168.110.10
--prop:guestinfo.domain=corp.local 
--prop:guestinfo.ntp=192.168.110.10
--prop:guestinfo.root_password=daniel1
--prop:guestinfo.preload=True 
--prop:guestinfo.nappautodeploy=true  
--prop:guestinfo.vip_pool=192.168.110.215-192.168.110.220  
--prop:guestinfo.nappfqdn=napp.corp.local
--prop:guestinfo.nsxmanager=192.168.110.201  
--prop:guestinfo.nsxuser=admin
--prop:guestinfo.nsxpassword=VMware1!VMware1!  
--prop:guestinfo.localcache=10.124.48.61
--prop:guestinfo.podnet=172.25.0.0/16'

ovftool --I:targetSessionTicket=$SESSIONID $COMMONOPTS --prop:guestinfo.role=master $SOURCE_MASTER $TARGET_MASTER
ovftool --I:targetSessionTicket=$SESSIONID $COMMONOPTS --prop:guestinfo.role=node   $SOURCE_NODE   $TARGET_NODE
