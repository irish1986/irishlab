#!/bin/bash

Red='\033[0;31m'
LightRed='\033[1;31m'
LightGreen='\033[1;32m'
LightPurple='\033[1;35m'
LightCyan='\033[1;36m'
NC='\033[0m'

Name='Proxmox / Cloud Init Image Creation Tool'
Dist='Ubuntu'

echo -e "${LightPurple}$Name"
echo -e "${LightPurple}$Dist"
echo ""

# Distro
VM_ID="9002"
STORAGE_NAME="ceph"
UBUNTU_DISTRO="jammy"
UBUNTU_VERSION="22.04"
IMAGE_FILE="${UBUNTU_DISTRO}-server-cloudimg-amd64.img"
IMAGE_URL="https://cloud-images.ubuntu.com/${UBUNTU_DISTRO}/current/${IMAGE_FILE}"
HASH_URL="https://cloud-images.ubuntu.com/${UBUNTU_DISTRO}/current/SHA256SUMS"
HASH_FILE="${UBUNTU_DISTRO}_SHA256SUMS"

# User Configuration
LAUNCHPAD_ID="irish1986"

# VM Configuration
SOCKETS="1"
CORES="1"
MEM_SIZE="1024"
DISK_SIZE="32G"
STORAGE_ISO="/mnt/pve/iso/cloud"
SNIPPETS="iso"

echo ""
echo "VM_ID................: $VM_ID"
echo "UBUNTU_DISTRO........: $UBUNTU_DISTRO"
echo "UBUNTU_VERSION.......: $UBUNTU_VERSION"
echo "STORAGE_NAME.........: $STORAGE_NAME"
echo "STORAGE_ISO..........: $STORAGE_ISO"
echo "STORAGE_SNIPPETS.....: $SNIPPETS"
echo "IMAGE_FILE...........: $IMAGE_FILE"
echo "IMAGE_URL............: $IMAGE_URL"
echo "HASH_URL.............: $HASH_URL"
echo "HASH_FILE............: $HASH_FILE"
echo "LAUNCHPAD_ID.........: $LAUNCHPAD_ID"
echo ""

function setStatus(){

    description=$1
    severity=$2

    logger "$Name $Version: [${severity}] $description"

    case "$severity" in
        s)
            echo -e "[${LightGreen}+${NC}] ${LightGreen}${description}${NC}"
        ;;
        f)
            echo -e "[${Red}-${NC}] ${LightRed}${description}${NC}"
        ;;
        q)
            echo -e "[${LightPurple}?${NC}] ${LightPurple}${description}${NC}"
        ;;
        *)
            echo -e "[${LightCyan}*${NC}] ${LightCyan}${description}${NC}"
        ;;
    esac

    [[ $WithVoice -eq 1 ]] && echo -e ${description} | espeak
}

function "$runCommand"(){

    beforeText=$1
    afterText=$2
    commandToRun=$3

    setStatus "${beforeText}" "s"

    eval $commandToRun

    setStatus "$afterText" "s"

}

setStatus "STEP 1: Get Ubuntu Cloud image and SHA256 hash" "*"

HASHES_MATCH=-1
ATTEMPT=0

while [ $HASHES_MATCH -lt 1 ]
do

    ATTEMPT=$((ATTEMPT+1))

    setStatus "Checking to see if '${IMAGE_FILE}-orig' has been downloaded (attempt: $ATTEMPT)..." "*"
    if [ ! -f ${STORAGE_ISO}/${IMAGE_FILE}-orig ]; then
        setStatus " - File not found." "f"
        setStatus " - Downloading file from internet (${IMAGE_URL})..." "*"

        if wget ${IMAGE_URL} -v --output-document=${STORAGE_ISO}/${IMAGE_FILE}-orig ; then
            setStatus " - Complete." "s"
        else
            setStatus " - Download failed." "f"
        fi
    else
        setStatus " - File found." "s"
        if [ "$HASHES_MATCH" -eq "0" ]; then
            setStatus " - SHA256 hashes do not match. File is invalid." "f"
            setStatus " - Downloading file from internet and overwriting invalid, local file (${IMAGE_URL})..." "*"
            if wget ${IMAGE_URL} -v --output-document=${STORAGE_ISO}/${IMAGE_FILE}-orig ; then
                setStatus " - Complete." "s"
            else
                setStatus " - Download failed." "f"
            fi
        fi
    fi

    setStatus "Generating SHA256 hash from the file on-disk..." "*"
    SHA256_HASH_ONDISK=`sha256sum ${STORAGE_ISO}/${IMAGE_FILE}-orig | cut -d ' ' -f1`
    setStatus " - Done: $SHA256_HASH_ONDISK" "s"

    setStatus "Downloading SHA256 sums from Ubuntu (${HASH_URL})..." "*"
    if wget -q -N ${HASH_URL} --output-document=${STORAGE_ISO}/${HASH_FILE} ; then
        setStatus " - Extracting SHA256 hash from Ubuntu (${HASH_FILE})..." "*"
        SHA256_HASH_FROMINET=`grep "${IMAGE_FILE}" ${STORAGE_ISO}/${HASH_FILE} | cut -d ' ' -f1`
        setStatus " - Done: $SHA256_HASH_FROMINET" "s"
    else
        setStatus " - Download of SHA245 hashes failed." "f"
        exit -2
    fi

    setStatus "Comparing SHA256 hashes..." "*"
    if [[ "$SHA256_HASH_ONDISK" != "$SHA256_HASH_FROMINET" ]]; then
        HASHES_MATCH=0
        setStatus " - Hashes do NOT match. Retrying..." "f"
    else
        HASHES_MATCH=1
        setStatus " - Hashes match." "s"
    fi

    if [ $ATTEMPT -gt 3 ]; then
        setStatus "FATAL: Can't seem to download a valid image and confirm the \
            SHA256 hash after 3 attempts. Cannot continue." "f"
        exit -1
    fi

done

cp ${STORAGE_ISO}/${IMAGE_FILE}-orig ${STORAGE_ISO}/${IMAGE_FILE}

setStatus "STEP 1b: Purge existing VM template (${VM_ID}) if it already exists."
if qm destroy ${VM_ID} --purge ; then
    setStatus " - Successfully deleted." "s"
else
    setStatus " - No existing template found." "s"
fi

setStatus "STEP 1c: Configure VM template with software."
if virt-customize -a ${STORAGE_ISO}/${IMAGE_FILE} --install git,qemu-guest-agent,watchdog \
    --run-command "cat /dev/null > /etc/machine-id"; then
    setStatus " - Successfully installed." "s"
else
    setStatus " - Unable to install software into image file ${STORAGE_ISO}/${IMAGE_FILE}." "s"
fi

setStatus "STEP 2: Create a virtual machine" "*"
if qm create ${VM_ID}  \
    --name ubuntu-cloud-${UBUNTU_DISTRO} \
    --description "Ubuntu '${UBUNTU_DISTRO}' '${UBUNTU_VERSION}' cloud image `date`" \
    --sockets ${SOCKETS} --cores ${CORES} --memory ${MEM_SIZE} \
    --agent 1 --autostart 1 --onboot 1 --ostype l26 \
    --net0 virtio,bridge=vmbr0 \
    --cpu cputype=host --watchdog model=i6300esb,action=reset \
    --tags ubuntu,ubuntu-${UBUNTU_DISTRO},ubuntu-${UBUNTU_VERSION},cloud-image; then
    setStatus " - Success." "s"
else
    setStatus " - Error completing step." "f"
    exit -1
fi

setStatus "STEP 3: Import the disk into the proxmox storage, into '${STORAGE_NAME}' in this case."
if qm importdisk ${VM_ID} ${STORAGE_ISO}/${IMAGE_FILE} ${STORAGE_NAME} ; then
    setStatus " - Success." "s"
else
    setStatus " - Error completing step." "f"
    exit -1
fi

setStatus "STEP 4: Add the new, imported disk to the VM."
STORAGE_TYPE=$(pvesm status --storage ${STORAGE_NAME} | awk 'NR == 2 {print $2}')
if [ "$STORAGE_TYPE" = "dir" ]; then
  setStatus " - Storage type 'Directory' detected."
  IMPORTED_DISKFILE=${STORAGE_NAME}:${VM_ID}/vm-${VM_ID}-disk-0.raw
  rm ${IMPORTED_DISKFILE}
elif [ "$STORAGE_TYPE" = "lvm" ]; then
  setStatus " - Storage type 'LVM' detected."
  IMPORTED_DISKFILE=${STORAGE_NAME}:vm-${VM_ID}-disk-0
  lvremove ${IMPORTED_DISKFILE}
elif [ "$STORAGE_TYPE" = "lvmthin" ]; then
  setStatus " - Storage type 'LVM-Thin' detected."
  IMPORTED_DISKFILE=${STORAGE_NAME}:vm-${VM_ID}-disk-0
  lvremove ${IMPORTED_DISKFILE}
elif [ "$STORAGE_TYPE" = "rbd" ]; then
  setStatus " - Storage type 'RBD' detected."
  IMPORTED_DISKFILE=${STORAGE_NAME}:vm-${VM_ID}-disk-0
  rm ${IMPORTED_DISKFILE}
elif [ "$STORAGE_TYPE" = "zfspool" ]; then
  setStatus " - Storage type 'ZFS Pool' detected."
  IMPORTED_DISKFILE=${STORAGE_NAME}/vm-${VM_ID}-disk-0
  zfs destroy ${IMPORTED_DISKFILE}
else
  setStatus " - Storage type not detected. Defaulting to treating as Directory storage."
  IMPORTED_DISKFILE=${STORAGE_NAME}:${VM_ID}/vm-${VM_ID}-disk-0.raw
fi
sleep 1

if qm set ${VM_ID} --scsihw virtio-scsi-pci --scsi0 ${IMPORTED_DISKFILE},discard=on,ssd=1 ; then
    setStatus " - Success." "s"
else
    setStatus " - Error completing step." "f"
    exit -1
fi

setStatus "STEP 4a: Add a CD-ROM."
if qm set ${VM_ID} --ide2 ${STORAGE_NAME}:cloudinit ; then
    setStatus " - Success." "s"
else
    setStatus " - Error completing step." "f"
    exit -1
fi

setStatus "STEP 4b: Load cloud-init configuration to (${VM_ID})"
if qm set ${VM_ID} --cicustom \
    "meta=${SNIPPETS}:snippets/ubuntu-meta.yml,user=${SNIPPETS}:snippets/ubuntu-user.yml" ; then
    setStatus " - Success." "s"
else
    setStatus " - No existing template found." "s"
fi

setStatus "STEP 5: Specify the boot disk."
if qm set ${VM_ID} --boot c --bootdisk scsi0 ; then
    setStatus " - Success." "s"
else
    setStatus " - Error completing step." "f"
    exit -1
fi

setStatus "STEP 5a: Resize boot disk to ${DISK_SIZE}GB"

ATTEMPT=0
while [ $ATTEMPT -lt 5 ];
do
    ATTEMPT=$((ATTEMPT + 1))

    if qm resize ${VM_ID} scsi0 ${DISK_SIZE} ; then
        setStatus " - Success." "s"
        ATTEMPT=100
    else
        if [ $ATTEMPT -lt 5 ] ; then
            setStatus " - Error executing step. Retrying..." "f"
        else
            setStatus " - Error completing step." "f"
            exit -1
        fi
    fi
done
setStatus " - Refreshing view of drives, and waiting for I/O to catch up..."
qm rescan --vmid ${VM_ID}

setStatus "STEP 6: Convert VM to a template"
if qm template ${VM_ID} ; then
    setStatus " - Success." "s"
else
    setStatus " - Error completing step." "f"
    exit -1
fi

echo "======================================================================"
echo "S U M M A R Y"
echo "======================================================================"
echo "New VM template based on Ubuntu '$UBUNTU_DISTRO' was created as VM_ID"
echo "$VM_ID on ProxMox server $(hostname). It has $CORES CPU cores and ${MEM_SIZE}"
echo "of RAM. The primary '/' mount point has ${DISK_SIZE} of space. Login with:"
echo ""
echo "======================================================================"
echo "T E M P L A T E  C O N F I G"
echo "======================================================================"
qm config ${VM_ID} | grep -v sshkeys | column -t -s' '
echo ""
