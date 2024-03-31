variable "node" {
  description = "Proxmox Node ID"
  type        = string
  default     = "pve-1"
}

variable "id" {
  description = "Proxmox VM ID"
  type        = string
}

variable "hostname" {
  description = "Proxmox VM Name"
  type        = string
}

variable "tags" {
  description = "Proxmox Tag"
  type        = string
}

variable "description" {
  description = "Proxmox Description"
  type        = string
}

variable "pool" {
  description = "Proxmox Pool"
  type        = string
}

variable "os" {
  description = "Proxmox Pool"
  default     = "ubuntu-lts"
  type        = string
}

variable "size" {
  default = "small"
}

variable "ip_address" {
  type = string
}

variable "gateway" {
  type = string
}
