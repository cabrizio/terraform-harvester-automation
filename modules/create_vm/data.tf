data "harvester_image" "this" {
  display_name = "ubuntu-24.04-server-cloudimg-amd64.img"
  namespace    = var.vm_namespace
}

data "harvester_ssh_key" "this" {
  name      = "basic-ssh-key"
  namespace = var.vm_namespace
}
