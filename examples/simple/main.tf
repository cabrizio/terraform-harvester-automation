# create a vm using the ../modules

module "ubuntu24" {
  source          = "../../"
  vm_name         = var.vm_name
  vm_namespace    = var.vm_namespace
  vm_description  = var.vm_description
  vm_cpu          = 4
  vm_memory       = var.vm_memory
  vm_disk_size    = var.vm_disk_size
  vm_network_name = var.vm_network_name
  vm_ssh_key      = var.vm_ssh_key
  run_ansible     = var.run_ansible
}

output "all" {
  value = module.ubuntu24
}
