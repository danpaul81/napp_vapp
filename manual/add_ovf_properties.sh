#!/bin/bash


#debug settings, comment on prod system
#PHOTON_APPLIANCE_NAME="NAPP_Appliance"
#FINAL_PHOTON_APPLIANCE_NAME="NAPP_Appliance"
#PHOTON_NETWORK="OL_SEG_10"
#VAPP_OVF_TEMPLATE="vapp.xml.template"
#

ORIGPATH=$(pwd)
cd ..
OUTPUT_PATH="$(pwd)/output-vsphere-iso"
cd $ORIGPATH

VAPP_OVF=${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}/${PHOTON_APPLIANCE_NAME}_vapp.ovf
VAPP_MF=${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}/${PHOTON_APPLIANCE_NAME}_vapp.mf


# copy OVF files from packer output
cp ${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}/${PHOTON_APPLIANCE_NAME}.ovf ${VAPP_OVF}


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

echo "replacements done"

#setup Virtual System for napp master
    #modify name
    sed -i "s/<VirtualSystem.*/<VirtualSystem ovf:id=\"${PHOTON_APPLIANCE_NAME}_${PHOTON_VERSION}_master\">/g" $VIRTUALSYSTEM1_TEMP
    sed -i "s/<Name>.*<\/Name>/<Name>${PHOTON_APPLIANCE_NAME}_${PHOTON_VERSION}_master<\/Name>/g" $VIRTUALSYSTEM1_TEMP
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
    sed -i "s/<VirtualSystem.*/<VirtualSystem ovf:id=\"${PHOTON_APPLIANCE_NAME}_${PHOTON_VERSION}_node\">/g" $VIRTUALSYSTEM2_TEMP
    sed -i "s/<Name>.*<\/Name>/<Name>${PHOTON_APPLIANCE_NAME}_${PHOTON_VERSION}_node<\/Name>/g" $VIRTUALSYSTEM2_TEMP
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
    </ProductSection>
  </VirtualSystem>
EOF
echo "done virtual systems mods"

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


#####
## STEP 2:  Create vapp & cleanup
#####

#generate manifest with hash
cd ${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}
openssl sha1 ${PHOTON_APPLIANCE_NAME}_vapp.ovf ${PHOTON_APPLIANCE_NAME}-disk-0.vmdk > ${VAPP_MF}
cd $ORIGPATH

ovftool ${VAPP_OVF} ${OUTPUT_PATH}/${FINAL_PHOTON_APPLIANCE_NAME}_vapp.ova
chmod a+r ${OUTPUT_PATH}/${FINAL_PHOTON_APPLIANCE_NAME}_vapp.ova

#rm -rf ${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}

