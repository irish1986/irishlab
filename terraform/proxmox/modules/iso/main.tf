terraform {
  required_providers {
    dns = {
      source  = "hashicorp/dns"
      version = "3.4.0"
    }
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.14"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.1"
    }
  }
}

locals {
  operating_system = {
    "ubuntu-lts" = {
      os   = "ubuntu-cloud-jammy"
      type = "l26"
    }
  }
  sizing = {
    "pico" = {
      sockets = 1
      cores   = 1
      memory  = 512
      disk    = "8G"
    }
    "small" = {
      sockets = 1
      cores   = 1
      memory  = 1024
      disk    = "8G"
    }
    "medium" = {
      sockets = 1
      cores   = 2
      memory  = 2048
      disk    = "16G"
    }
    "large" = {
      sockets = 1
      cores   = 4
      memory  = 4096
      disk    = "32G"
    }
    "xlarge" = {
      sockets = 1
      cores   = 4
      memory  = 8192
      disk    = "32G"
    }
  }
}

resource "proxmox_vm_qemu" "vm-iso" {
  target_node = var.node

  vmid = var.id
  name = var.hostname
  tags = var.tags
  desc = var.description
  pool = var.pool

  iso     = "local:iso/ubuntu-20.04.4-live-server-amd64.iso"
  os_type = "ubuntu"
  bios    = "seabios"
  agent   = 1

  cpu     = "host"
  numa    = true
  sockets = local.sizing[var.size].sockets
  cores   = local.sizing[var.size].cores
  memory  = local.sizing[var.size].memory

  scsihw = "virtio-scsi-single"
  disk {
    slot    = 0
    type    = "scsi"
    storage = "ceph"
    size    = local.sizing[var.size].disk
    backup  = true
  }

  network {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

}
