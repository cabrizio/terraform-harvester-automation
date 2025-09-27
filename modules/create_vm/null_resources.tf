resource "null_resource" "vm_disk_resize_handler" {
  count = var.vm_disk_size != "20Gi" ? 1 : 0

  triggers = {
    disk_size = var.vm_disk_size
    vm_name   = var.vm_name
    namespace = var.vm_namespace
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/vm_disk_resize.sh ${var.vm_name} ${var.vm_namespace} ${var.vm_disk_size}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
