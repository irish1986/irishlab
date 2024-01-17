terraform {
  required_version = ">= 0.15"
  required_providers {
    dns = {
      source  = "hashicorp/dns"
      version = "3.3.2"
    }
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

# credentials.auto.tfvars
provider "proxmox" {
  pm_api_url        = var.proxmox_api_url
  pm_user           = var.proxmox_user
  pm_password       = var.proxmox_password
  pm_parallel       = 3
  pm_tls_insecure   = true
}

locals {
  lxc_files  = fileset(".", "lxc/*.yml")
  lxc        = { for file in local.lxc_files : basename(file) => yamldecode(file(file)) }
  iso_files  = fileset(".", "iso/*.yml")
  iso        = { for file in local.iso_files : basename(file) => yamldecode(file(file)) }
  vm_files  = fileset(".", "vm/*.yml")
  vm        = { for file in local.vm_files : basename(file) => yamldecode(file(file)) }
}

module "vm_resource" {
  source      = "./modules/vm"
  for_each    = local.vm

  node        = each.value.node

  id          = each.value.id
  hostname    = each.value.hostname
  tags        = each.value.tags
  description = each.value.description
  pool        = each.value.pool

  os          = each.value.os
  size        = each.value.size
  ip_address  = each.value.ip_address
  gateway     = each.value.gateway
}
