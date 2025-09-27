# Output Ansible execution information
output "ansible_execution_info" {
  description = "Ansible execution information"
  value = {
    playbook_path  = var.ansible_playbook_path
    inventory_path = var.ansible_inventory_path
    target_vm_ip   = try(var.vm_ip_address, "unknown")
    ansible_user   = var.ansible_user
    run_ansible    = var.run_ansible
    manual_command = "ansible-playbook -i ${var.ansible_inventory_path} ${var.ansible_playbook_path} --become"
  }
}
