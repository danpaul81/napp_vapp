#!/bin/bash


#debug settings, comment on prod system
#PHOTON_APPLIANCE_NAME="NAPP-Appliance"
#FINAL_PHOTON_APPLIANCE_NAME="NAPP-Appliance_0.1.5"
#PHOTON_NETWORK="OL_SEG_10"
#PHOTON_VERSION="0.1.5"
#VAPP_OVF_TEMPLATE="vapp.xml.template"
#APP_MASTER_OVF_TEMPLATE="app.master.xml.template"
#APP_NODE_OVF_TEMPLATE="app.node.xml.template"
#

ORIGPATH=$(pwd)
cd ..
OUTPUT_PATH="$(pwd)/output-vsphere-iso"
cd $ORIGPATH

VAPP_OVF=${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}/${PHOTON_APPLIANCE_NAME}_vapp.ovf
VAPP_MF=${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}/${PHOTON_APPLIANCE_NAME}_vapp.mf

MASTER_APP_OVF=${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}/${PHOTON_APPLIANCE_NAME}_master_app.ovf
MASTER_APP_MF=${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}/${PHOTON_APPLIANCE_NAME}_master_app.mf

NODE_APP_OVF=${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}/${PHOTON_APPLIANCE_NAME}_node_app.ovf
NODE_APP_MF=${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}/${PHOTON_APPLIANCE_NAME}_node_app.mf

# copy OVF files from packer output
cp ${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}/${PHOTON_APPLIANCE_NAME}.ovf ${VAPP_OVF}
cp ${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}/${PHOTON_APPLIANCE_NAME}.ovf ${MASTER_APP_OVF}
cp ${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}/${PHOTON_APPLIANCE_NAME}.ovf ${NODE_APP_OVF}

#####
## STEP 1:  Modify files for vapp
#####

# set outputfiles for virtual systems
VIRTUALSYSTEM1_TEMP=${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}/VirtualSystem1.xml.temp
VIRTUALSYSTEM2_TEMP=${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}/VirtualSystem2.xml.temp

rm -f ${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}/${PHOTON_APPLIANCE_NAME}.mf
rm -f ${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}/*.temp

#replace envelope with simple one -> xmlstarlet doesnt work with original...
sed -i 's/<Envelope.*/<Envelope>/g' $VAPP_OVF

#extract VirtualSystem definition
xmlstarlet sel -t -c '/Envelope/VirtualSystem' $VAPP_OVF > $VIRTUALSYSTEM1_TEMP 2>/dev/null
xmlstarlet -L  ed -d '/Envelope/VirtualSystem' $VAPP_OVF 2>/dev/null

#duplicate virtual system definition
cp $VIRTUALSYSTEM1_TEMP $VIRTUALSYSTEM2_TEMP

# save disksizes from original OVF
DISKSIZE1=$(grep "${PHOTON_APPLIANCE_NAME}-disk-0.vmdk" $VAPP_OVF |cut -d\" -f6)
#DISKSIZE2=$(grep "${PHOTON_APPLIANCE_NAME}-disk-1.vmdk" $VAPP_OVF |cut -d\" -f6)

# replace packer-created OVF with template
cp $VAPP_OVF_TEMPLATE $VAPP_OVF

# replace version/name/disksize/network in template
sed -i "s/{{VERSION}}/${PHOTON_VERSION}/g" $VAPP_OVF
sed -i "s/{{APPLIANCENAME}}/${PHOTON_APPLIANCE_NAME}/g" $VAPP_OVF
sed -i "s/{{DISKSIZE1}}/${DISKSIZE1}/g" $VAPP_OVF
#sed -i "s/{{DISKSIZE2}}/${DISKSIZE2}/g" $VAPP_OVF
sed -i "s/{{NETWORK}}/${PHOTON_NETWORK}/g" $VAPP_OVF

echo "VAPP replacements done"

#setup Virtual System for napp master
    #modify name
    sed -i "s/<VirtualSystem.*/<VirtualSystem ovf:id=\"${PHOTON_APPLIANCE_NAME}-${PHOTON_VERSION}-master\">/g" $VIRTUALSYSTEM1_TEMP
    sed -i "s/<Name>.*<\/Name>/<Name>${PHOTON_APPLIANCE_NAME}-${PHOTON_VERSION}-master<\/Name>/g" $VIRTUALSYSTEM1_TEMP
    #remove last tag and add new footer
    sed -i "/  <\/VirtualSystem>/d" $VIRTUALSYSTEM1_TEMP
    # modify original vmdisk1/vmdisk2 to vmdisk1/vmdisk3
    sed -i "s/vmdisk2/vmdisk3/g" $VIRTUALSYSTEM1_TEMP

    cat >>$VIRTUALSYSTEM1_TEMP <<EOF
    <ProductSection>
     <Info>Information about the installed software</Info>
      <Property ovf:userConfigurable="false" ovf:value="master" ovf:type="string" ovf:key="guestinfo.role">
	<Label>NAPP Role</Label>
        <Description>is this NAPP master?</Description>
      </Property>
    </ProductSection>
  </VirtualSystem>
EOF
#setup Virtual System for napp node
    #modify name
    sed -i "s/<VirtualSystem.*/<VirtualSystem ovf:id=\"${PHOTON_APPLIANCE_NAME}-${PHOTON_VERSION}-node\">/g" $VIRTUALSYSTEM2_TEMP
    sed -i "s/<Name>.*<\/Name>/<Name>${PHOTON_APPLIANCE_NAME}-${PHOTON_VERSION}-node<\/Name>/g" $VIRTUALSYSTEM2_TEMP
    #remove last tag and add new footer
    sed -i "/  <\/VirtualSystem>/d" $VIRTUALSYSTEM2_TEMP
    #modify original vmdisk1/vmdisk2 to vmdisk2/vmdisk4
    sed -i "s/vmdisk2/vmdisk4/g" $VIRTUALSYSTEM2_TEMP
    sed -i "s/vmdisk1/vmdisk2/g" $VIRTUALSYSTEM2_TEMP
    
    #modify CPU settings for node
    sed -i "s/2 virtual CPU(s)/16 virtual CPU(s)/g" $VIRTUALSYSTEM2_TEMP
    sed -i "s/VirtualQuantity>2</VirtualQuantity>16</g" $VIRTUALSYSTEM2_TEMP
    #modify RAM Settings for node
    sed -i "s/4096MB of memory/65536MB of memory/g" $VIRTUALSYSTEM2_TEMP
    sed -i "s/VirtualQuantity>4096</VirtualQuantity>65536</g" $VIRTUALSYSTEM2_TEMP

    cat >>$VIRTUALSYSTEM2_TEMP <<EOF
    <ProductSection>
      <Info>Information about the installed software</Info>
      <Property ovf:userConfigurable="false" ovf:value="node" ovf:type="string" ovf:key="guestinfo.role">
       <Label>NAPP Role</Label>
       <Description>is this VM NAPP node?</Description>
      </Property>
      <Property ovf:userConfigurable="false" ovf:value="1" ovf:type="string" ovf:key="guestinfo.nodenum">
       <Label>Node Number</Label>
       <Description>When deploying multiple worker nodes please specify which node this is</Description>
      </Property>
    </ProductSection>
  </VirtualSystem>
EOF
echo "VAPP virtual systems mods done"

cat $VIRTUALSYSTEM1_TEMP >>$VAPP_OVF
cat $VIRTUALSYSTEM2_TEMP >>$VAPP_OVF

cat >>$VAPP_OVF <<EOF
  </VirtualSystemCollection>
</Envelope>
EOF

# replace network used by packer with generic one
sed -i "s/${PHOTON_NETWORK}/VM_Network/g" $VAPP_OVF

sed -i 's/<VirtualHardwareSection>/<VirtualHardwareSection ovf:transport="com.vmware.guestInfo">/g' $VAPP_OVF
sed -i '/^      <vmw:ExtraConfig ovf:required="false" vmw:key="nvram".*$/d' $VAPP_OVF
sed -i "/^    <File ovf:href=\"${PHOTON_APPLIANCE_NAME}-file1.nvram\".*$/d" $VAPP_OVF

echo "VAPP manifests build"

#####
## STEP 2: create templates for single vm master / node appliances
#####

TEMPLATENETWORK=$(grep "Network ovf:name" $MASTER_APP_OVF |cut -d\" -f2)

# STEP 2.1 Modify settings for master VM
sed -i "s/${TEMPLATENETWORK}/VM_Network/g" $MASTER_APP_OVF
sed -i "s/<VirtualSystem.*/<VirtualSystem ovf:id=\"${PHOTON_APPLIANCE_NAME}_${PHOTON_VERSION}-master\">/g" $MASTER_APP_OVF
sed -i 's/<VirtualHardwareSection>/<VirtualHardwareSection ovf:transport="com.vmware.guestInfo">/g' $MASTER_APP_OVF
sed -i "/    <\/vmw:BootOrderSection>/ r ${APP_MASTER_OVF_TEMPLATE}" $MASTER_APP_OVF
sed -i "s/{{VERSION}}/${PHOTON_VERSION}/g" $MASTER_APP_OVF
sed -i '/^      <vmw:ExtraConfig ovf:required="false" vmw:key="nvram".*$/d' $MASTER_APP_OVF
sed -i "/^    <File ovf:href=\"${PHOTON_APPLIANCE_NAME}-file1.nvram\".*$/d" $MASTER_APP_OVF
sed -i "s/<Name>${PHOTON_APPLIANCE_NAME}<\/Name>/<Name>${PHOTON_APPLIANCE_NAME}-master<\/Name>/g" $MASTER_APP_OVF
sed -i "s/{{ROLEPRODUCT}}/${PHOTON_APPLIANCE_NAME}-master/g" $MASTER_APP_OVF
sed -i "s/{{ROLE}}/master/g" $MASTER_APP_OVF

# STEP 2.2 Modify settings for node VM and customize HW settings for Node (CPU, RAM, DISK)
sed -i "s/${TEMPLATENETWORK}/VM_Network/g" $NODE_APP_OVF
sed -i "s/<VirtualSystem.*/<VirtualSystem ovf:id=\"${PHOTON_APPLIANCE_NAME}_${PHOTON_VERSION}-node\">/g" $NODE_APP_OVF
sed -i 's/<VirtualHardwareSection>/<VirtualHardwareSection ovf:transport="com.vmware.guestInfo">/g' $NODE_APP_OVF
sed -i "/    <\/vmw:BootOrderSection>/ r ${APP_NODE_OVF_TEMPLATE}" $NODE_APP_OVF
sed -i "s/{{VERSION}}/${PHOTON_VERSION}/g" $NODE_APP_OVF
sed -i '/^      <vmw:ExtraConfig ovf:required="false" vmw:key="nvram".*$/d' $NODE_APP_OVF
sed -i "/^    <File ovf:href=\"${PHOTON_APPLIANCE_NAME}-file1.nvram\".*$/d" $NODE_APP_OVF

sed -i "s/<Disk ovf:capacity=\"10\" ovf:capacityAllocationUnits=\"byte \* 2^20/<Disk ovf:capacity=\"1000\" ovf:capacityAllocationUnits=\"byte \* 2^30/g" $NODE_APP_OVF
#modify CPU settings for node
sed -i "s/2 virtual CPU(s)/16 virtual CPU(s)/g" $NODE_APP_OVF
sed -i "s/VirtualQuantity>2</VirtualQuantity>16</g" $NODE_APP_OVF
#modify RAM Settings for node
sed -i "s/4096MB of memory/65536MB of memory/g" $NODE_APP_OVF
sed -i "s/VirtualQuantity>4096</VirtualQuantity>65536</g" $NODE_APP_OVF
# set names/roles
sed -i "s/<Name>${PHOTON_APPLIANCE_NAME}<\/Name>/<Name>${PHOTON_APPLIANCE_NAME}-node<\/Name>/g" $NODE_APP_OVF
sed -i "s/{{ROLEPRODUCT}}/${PHOTON_APPLIANCE_NAME}-node/g" $NODE_APP_OVF
sed -i "s/{{ROLE}}/node/g" $NODE_APP_OVF


#####
## STEP 3:  Create vapp, appliances & cleanup
#####

#generate manifest with hash
cd ${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}
echo "Creating VAPP HASH"
openssl sha1 ${PHOTON_APPLIANCE_NAME}_vapp.ovf ${PHOTON_APPLIANCE_NAME}-disk-0.vmdk > ${VAPP_MF}
echo "Creating APP Master HASH"
openssl sha1 ${PHOTON_APPLIANCE_NAME}_master_app.ovf ${PHOTON_APPLIANCE_NAME}-disk-0.vmdk ${PHOTON_APPLIANCE_NAME}-disk-1.vmdk > ${MASTER_APP_MF}
echo "Creating APP Node HASH"
openssl sha1 ${PHOTON_APPLIANCE_NAME}_node_app.ovf ${PHOTON_APPLIANCE_NAME}-disk-0.vmdk ${PHOTON_APPLIANCE_NAME}-disk-1.vmdk > ${NODE_APP_MF}
cd $ORIGPATH

echo "Build VAPP OVA"
ovftool ${VAPP_OVF} ${OUTPUT_PATH}/${FINAL_PHOTON_APPLIANCE_NAME}_vapp.ova
chmod a+r ${OUTPUT_PATH}/${FINAL_PHOTON_APPLIANCE_NAME}_vapp.ova

echo "Build Master OVA"
ovftool ${MASTER_APP_OVF} ${OUTPUT_PATH}/${FINAL_PHOTON_APPLIANCE_NAME}_master_app.ova
chmod a+r ${OUTPUT_PATH}/${FINAL_PHOTON_APPLIANCE_NAME}_master_app.ova

echo "Build Node OVA"
ovftool ${NODE_APP_OVF} ${OUTPUT_PATH}/${FINAL_PHOTON_APPLIANCE_NAME}_node_app.ova
chmod a+r ${OUTPUT_PATH}/${FINAL_PHOTON_APPLIANCE_NAME}_node_app.ova

rm -rf ${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}

