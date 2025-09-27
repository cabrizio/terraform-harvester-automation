# variables.tf
variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "vm_namespace" {
  description = "Kubernetes namespace for the VM"
  type        = string
}

variable "vm_description" {
  description = "Description of the VM"
  type        = string
}

variable "vm_cpu" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "Memory size"
  type        = string
  default     = "4Gi"
}

variable "vm_disk_size" {
  description = "Disk size"
  type        = string
  default     = "20Gi"
}

variable "vm_network_name" {
  description = "Network name"
  type        = string
  default     = "default/vm-network"
}

variable "vm_ssh_key" {
  description = "SSH key path"
  type        = string
}

variable "run_ansible" {
  description = "Whether to run Ansible"
  type        = bool
  default     = false
}
