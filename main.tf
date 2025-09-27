# create a vm using the ../modules

module "this" {
  source          = "./modules/create_vm"
  vm_name         = var.vm_name
  vm_namespace    = var.vm_namespace
  vm_description  = var.vm_description
  vm_cpu          = var.vm_cpu
  vm_memory       = var.vm_memory
  vm_disk_size    = var.vm_disk_size
  vm_network_name = var.vm_network_name

}

module "ansible" {
  source                 = "./modules/ansible"
  vm_ip_address          = module.this.ip_address
  vm_id                  = module.this.vm_id
  vm_name                = module.this.hostname
  vm_ssh_key             = var.vm_ssh_key
  ansible_playbook_path  = "${path.module}/ansible/linux-playbook.yml"
  ansible_inventory_path = "${path.module}/ansible/inventory.ini"
  run_ansible            = try(var.run_ansible, false)
  ansible_extra_vars     = var.ansible_extra_vars

  depends_on = [
    module.this,
    null_resource.wait_for_vm
  ]
}
