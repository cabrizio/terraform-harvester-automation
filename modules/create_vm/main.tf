# Terraform module for creating a virtual VM on harvester

resource "harvester_virtualmachine" "this" {
  name                 = var.vm_name
  namespace            = var.vm_namespace
  restart_after_update = true

  description = var.vm_description
  tags = {
    provider = "terraform"
    team     = "platform"
  }

  cpu    = var.vm_cpu
  memory = var.vm_memory

  efi         = true
  secure_boot = true

  run_strategy    = "RerunOnFailure"
  hostname        = var.vm_name
  reserved_memory = "100Mi"
  machine_type    = "q35"

  network_interface {
    name           = "nic-1"
    wait_for_lease = true
    network_name   = var.vm_network_name
    type           = "bridge"
  }

  disk {
    name       = "rootdisk"
    type       = "disk"
    size       = "10Gi"
    bus        = "virtio"
    boot_order = 1

    image       = data.harvester_image.this.id
    auto_delete = true
  }

  disk {
    name        = "${var.vm_name}-disk"
    type        = "disk"
    size        = var.vm_disk_size
    bus         = "virtio"
    auto_delete = true
  }

  cloudinit {
    user_data_secret_name = harvester_cloudinit_secret.cloud-config-basic.name
  }

  lifecycle {
    ignore_changes = [
      network_interface,
      cloudinit
    ]
  }

  depends_on = [
    null_resource.vm_disk_resize_handler
  ]
}
