#! /bin/bash

USER="groot"
PASSWORD="test1234"
VMID=8200
STORAGE=local

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


set -x
rm -f noble-server-cloudimg-amd64.img
wget -q https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
qemu-img resize noble-server-cloudimg-amd64.img 8G
qm destroy $VMID
qm create $VMID \
    --name "ubuntu-noble-template" \
    --description "Ubuntu Noble 24.04" \
    --tags ubuntu,ubuntu-noble,ubuntu-24.04,cloud-image \
    --cpu cputype=host --sockets 1 --cores 1 --numa 1 \
    --memory 1024 --balloon 0 \
    --agent 1 --autostart 1 --onboot 1 --ostype l26 \
    --watchdog model=i6300esb,action=reset \
    --bios ovmf --machine q35 --efidisk0 $STORAGE:0,pre-enrolled-keys=0 \
    --net0 virtio,bridge=vmbr0,mtu=1
qm importdisk $VMID noble-server-cloudimg-amd64.img $STORAGE
qm set $VMID --scsihw -scsihw virtio-scsi-pci --scsi0  $STORAGE:vm-$VMID-disk-1,discard=on
qm set $VMID --boot c --bootdisk scsi0
qm set $VMID --ide2 $STORAGE:cloudinit

cat << EOF | sudo tee /var/lib/vz/snippets/ubuntu.yml
#cloud-config
runcmd:
    - apt-get update
    - apt-get install -y git,qemu-guest-agent,watchdog
    - systemctl start qemu-guest-agent
    - systemctl enable ssh
    - reboot
EOF

qm set $VMID --cicustom "vendor=local:snippets/ubuntu.yml"
qm set $VMID --ciuser $USER # --ciupgrade 1
# qm set $VMID --cipassword $(openssl passwd -6 $PASSWORD)
qm set $VMID --sshkeys ~/.ssh/authorized_keys
qm set $VMID --ipconfig0 ip=dhcp
# qm cloudinit update $VMID
qm template $VMID
