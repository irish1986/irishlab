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
