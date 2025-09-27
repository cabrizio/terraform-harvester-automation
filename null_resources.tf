resource "null_resource" "wait_for_vm" {
  depends_on = [module.this]

  provisioner "local-exec" {
    command = "${path.module}/scripts/wait_for_vm.sh ${module.this.ip_address} ansible ${var.vm_ssh_key}"
  }

  triggers = {
    vm_id      = module.this.vm_id
    vm_ip      = module.this.ip_address
    vm_ssh_key = var.vm_ssh_key
  }
}
