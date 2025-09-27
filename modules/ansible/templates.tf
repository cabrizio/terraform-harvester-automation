# Generate dynamic Ansible inventory
resource "local_file" "ansible_inventory" {

  content = templatefile("${path.module}/templates/inventory.tpl", {
    vm_ip       = var.vm_ip_address
    vm_hostname = var.vm_name
    ssh_user    = var.ansible_user
  })

  filename = var.ansible_inventory_path
}

# Generate Ansible configuration
resource "local_file" "ansible_config" {
  content = templatefile("${path.module}/templates/ansible.cfg.tpl", {
    inventory_path = var.ansible_inventory_path
    remote_user    = var.ansible_user
  })

  filename = "${dirname(var.ansible_playbook_path)}/ansible.cfg"
}
