variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "vm_namespace" {
  description = "Namespace of the virtual machine"
  type        = string
}

variable "vm_description" {
  description = "Description of the virtual machine"
  type        = string
}

variable "vm_cpu" {
  description = "CPU of the virtual machine"
  type        = number
}

variable "vm_memory" {
  description = "Memory of the virtual machine"
  type        = string
}

variable "vm_disk_size" {
  description = "Disk size of the virtual machine"
  type        = string
}

variable "vm_network_name" {
  description = "Network name for the virtual machine"
  type        = string
  default     = "harvester-mgmt"
}

variable "vm_ip_address" {
  description = "IP address for the virtual machine (optional)"
  type        = string
  default     = ""
}

variable "vm_id" {
  description = "The ID of the VM"
  type        = string
  default     = ""
}

variable "run_ansible" {
  description = "Whether to run Ansible playbook after VM creation"
  type        = bool
  default     = false
}

variable "vm_ssh_key" {
  description = "Path to the SSH private key for the VM"
  type        = string
  default     = ""
}

variable "ansible_extra_vars" {
  description = "Extra variables to pass to Ansible"
  type        = map(string)
  default     = {}
}
