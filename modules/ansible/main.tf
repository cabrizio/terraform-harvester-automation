resource "null_resource" "run_ansible_playbook" {
  count = var.run_ansible ? 1 : 0

  depends_on = [
    local_file.ansible_inventory,
    local_file.ansible_config
  ]

  triggers = {
    vm_ip          = var.vm_ip_address
    vm_id          = var.vm_id
    playbook_hash  = filemd5(var.ansible_playbook_path)
    inventory_hash = local_file.ansible_inventory.content_md5
    extra_vars     = jsonencode(var.ansible_extra_vars)
    tags           = var.ansible_tags
    skip_tags      = var.ansible_skip_tags
    ansible_user   = var.ansible_user
    vm_ssh_key     = var.vm_ssh_key
    timestamp      = timestamp()
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/run_ansible.sh ${var.ansible_playbook_path} ${var.ansible_inventory_path} ${var.vm_ip_address} ${var.ansible_user} ${var.vm_ssh_key} '${jsonencode(var.ansible_extra_vars)}' '${var.ansible_tags}' '${var.ansible_skip_tags}'"
  }
}
