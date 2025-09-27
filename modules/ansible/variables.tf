# Variables for Ansible configuration
variable "ansible_playbook_path" {
  description = "Path to the main Ansible playbook"
  type        = string
  default     = "./ansible/linux-playbook.yml"
}

variable "ansible_inventory_path" {
  description = "Path to Ansible inventory file"
  type        = string
  default     = "./ansible/inventory"
}

variable "ansible_user" {
  description = "Ansible remote user"
  type        = string
  default     = "ansible"
}

variable "run_ansible" {
  description = "Whether to run Ansible playbook after VM creation"
  type        = bool
  default     = true
}

variable "ansible_extra_vars" {
  description = "Extra variables to pass to Ansible"
  type        = map(string)
  default     = {}
}

variable "ansible_tags" {
  description = "Ansible tags to run (comma-separated)"
  type        = string
  default     = ""
}

variable "ansible_skip_tags" {
  description = "Ansible tags to skip (comma-separated)"
  type        = string
  default     = ""
}

variable "vm_ip_address" {
  description = "IP address of the VM to connect to"
  type        = string
  default     = ""
}

variable "vm_id" {
  description = "The ID of the VM"
  type        = string
  default     = ""
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
  default     = ""
}

variable "vm_ssh_key" {
  description = "Path to the SSH private key for Ansible"
  type        = string
  default     = "~/.ssh/id_rsa"
}
