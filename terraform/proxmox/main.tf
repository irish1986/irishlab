locals {
  lxc_files = fileset(".", "lxc/*.yml")
  lxc       = { for file in local.lxc_files : basename(file) => yamldecode(file(file)) }
  iso_files = fileset(".", "iso/*.yml")
  iso       = { for file in local.iso_files : basename(file) => yamldecode(file(file)) }
  vm_files  = fileset(".", "vm/*.yml")
  vm        = { for file in local.vm_files : basename(file) => yamldecode(file(file)) }
}

module "vm_resource" {
  source   = "./modules/vm"
  for_each = local.vm

  node = each.value.node

  id          = each.value.id
  hostname    = each.value.hostname
  tags        = each.value.tags
  description = each.value.description
  pool        = each.value.pool

  os         = each.value.os
  size       = each.value.size
  ip_address = each.value.ip_address
  gateway    = each.value.gateway
}
