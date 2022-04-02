#!/bin/bash

#session ID on VCD
SESSIONID=762dc6b821ec4be6aba044904217a826




#local path to ova sources
SOURCE_NODE='output-vsphere-iso/NAPP-Appliance_0.1.5_node_app.ova'

#VCD URL/org/vdc/vapp
#important: select different VAPP names for master/node
TARGET_NODE='vcloud://ams2-vcd01.oc.vmware.com/cloud?org=ams2-vcd01-emea-sddc-lt-labs-t&vdc=ams2-vcd01-emea-sddc-lt-labs-d-ovdc1&vapp=NAPP_ADD_NODE'

#
#review and corect. dont use simple root password as deployment might fail
COMMONOPTS='--noSSLVerify --diskMode=thin 
--prop:guestinfo.master_ip=192.168.110.210  
--prop:guestinfo.node_ip=192.168.110.213
--prop:guestinfo.netmask=24 
--prop:guestinfo.gateway=192.168.110.1  
--prop:guestinfo.dns=192.168.110.10
--prop:guestinfo.domain=corp.local 
--prop:guestinfo.ntp=192.168.110.10
--prop:guestinfo.root_password=daniel1
--prop:guestinfo.preload=True 
--prop:guestinfo.nodenum=3
--prop:guestinfo.localcache=10.124.48.61'

ovftool --I:targetSessionTicket=$SESSIONID $COMMONOPTS --prop:guestinfo.role=node $SOURCE_NODE   $TARGET_NODE
