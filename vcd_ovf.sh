#!/bin/bash

SESSIONID=6da64e4ea7284b89aec6d38840822144

#ovftool --noSSLVerify --I:targetSessionTicket=$SESSIONID --diskMode=thin  \
--prop:guestinfo.master_ip='192.168.110.210' \
--prop:guestinfo.node_ip='192.168.110.211' \
--prop:guestinfo.netmask='24' \
--prop:guestinfo.gateway='192.168.110.1' \
--prop:guestinfo.dns='192.168.110.10' \
--prop:guestinfo.domain='corp.local' \
--prop:guestinfo.ntp='192.168.110.10' \
--prop:guestinfo.root_password='VMware1!VMware1!' \
--prop:guestinfo.debug=False \
--prop:guestinfo.preload=False \
--prop:guestinfo.nappautodeploy=False \
--prop:guestinfo.vip_pool='192.168.110.200-192.168.110.205' \
--prop:guestinfo.nappfqdn='napp.corp.local' \
--prop:guestinfo.nsxmanager='192.168.110.201' \
--prop:guestinfo.nsxuser='admin' \
--prop:guestinfo.nsxpassword='VMware1!VMware1!' \
--prop:guestinfo.podnet='172.25.0.0/16' \
--prop:guestinfo.role='master' \
output-vsphere-iso/NAPP_Appliance_0.0.2_master_app.ova 'vcloud://ams2-vcd01.oc.vmware.com/cloud?org=ams2-vcd01-emea-sddc-lt-labs-t&vdc=ams2-vcd01-emea-sddc-lt-labs-d-ovdc1&vapp=NAPP_MASTER'

ovftool --noSSLVerify --I:targetSessionTicket=$SESSIONID --diskMode=thin  \
--prop:guestinfo.master_ip='192.168.110.210' \
--prop:guestinfo.node_ip='192.168.110.211' \
--prop:guestinfo.netmask='24' \
--prop:guestinfo.gateway='192.168.110.1' \
--prop:guestinfo.dns='192.168.110.10' \
--prop:guestinfo.domain='corp.local' \
--prop:guestinfo.ntp='192.168.110.10' \
--prop:guestinfo.root_password='VMware1!VMware1!' \
--prop:guestinfo.debug=False \
--prop:guestinfo.preload=False \
--prop:guestinfo.nappautodeploy=False \
--prop:guestinfo.vip_pool='192.168.110.200-192.168.110.205' \
--prop:guestinfo.nappfqdn='napp.corp.local' \
--prop:guestinfo.nsxmanager='192.168.110.201' \
--prop:guestinfo.nsxuser='admin' \
--prop:guestinfo.nsxpassword='VMware1!VMware1!' \
--prop:guestinfo.podnet='172.25.0.0/16' \
--prop:guestinfo.role='node' \
output-vsphere-iso/NAPP_Appliance_0.0.2_node_app.ova 'vcloud://ams2-vcd01.oc.vmware.com/cloud?org=ams2-vcd01-emea-sddc-lt-labs-t&vdc=ams2-vcd01-emea-sddc-lt-labs-d-ovdc1&vapp=NAPP_NODE'
