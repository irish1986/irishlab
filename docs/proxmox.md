# Proxmox Config

## Increase the Storage on "local" storage

1. Navigate to "datacenter -> storage"
2. Delete the "local-lvm" storage
3. SSH into your server and run the follwing commands

```shell
lvremove /dev/pve/data
lvresize -l +100%FREE /dev/pve/root
resize2fs /dev/mapper/pve-root
```

## AMD/Intel Microcode

## Realtek R8125B driver

cd /tmp
wget <https://github.com/awesometic/realtek-r8125-dkms/releases/download/9.012.03-2/realtek-r8125-dkms_9.012.03-2_amd64.deb>
sudo dpkg -i realtek-r8125-dkms*.deb
sudo apt install --fix-broken

lsmod | grep -i r8169
lspci -k

sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y

## Intel iGPU Passthrough

```shell
nano /etc/default/grub
#GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on"

update-grub

nano /etc/modules
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
update-initramfs -u -k all

reboot
```

## nVidia GPU Passthrough

## Google Coral TPU Passthrough

```shell
nano /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt pcie_aspm=off initcall_blacklist=sysfb_init"

update-grub

nano /etc/modules
vfio
vfio_iommu_type1
vfio_pci
kvmgt
xengt
vfio-mdev

update-initramfs -u -k all
reboot

nano /etc/modprobe.d/blacklist-apex.conf
blacklist gasket
blacklist apex
options vfio-pci ids=1ac1:089a

update-initramfs -u -k all
lsmod | grep apex
```
