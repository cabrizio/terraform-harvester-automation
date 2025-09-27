#Example TFVARS for creating s simple VM
vm_name         = "example-vm"
vm_namespace    = "development"
vm_description  = "Example VM created with Terraform"
vm_memory       = "2Gi"
vm_disk_size    = "20Gi"
vm_network_name = "edge/vm-network"
run_ansible     = false
vm_ssh_key      = "../ansible/demo-key"
vm_cpu          = 4
