# Terraform Harvester Automation

**Terraform Harvester Automation** is a complete Infrastructure-as-Code (IaC) solution for automating VM lifecycle management on [Harvester](https://harvesterhci.io).  
It streamlines VM provisioning, post-deployment configuration, and CI/CD integration—reducing manual effort, increasing reliability, and ensuring consistent environments.
Terraform Harvester Automation provides a complete Infrastructure-as-Code framework for deploying and managing Harvester VMs, reducing manual work and enabling scalable CI/CD workflows.

## Why Use This Module?
Many engineering teams struggle with:
- **Slow manual provisioning** of Harvester VMs
- **Inconsistent configuration** across environments
- **Lack of automation** in CI/CD pipelines
- **Limited observability** during VM lifecycle management

This module solves these problems by providing:
- **One-command automation** for creating and managing Harvester VMs  
- **Optional Ansible integration** for post-provisioning configuration  
- **CI/CD-ready pipelines** for Jenkins and other orchestrators  
- **Flexible scaling** with batch VM creation capabilities  

With this module, teams can accelerate development, cut infrastructure setup time, and reduce operational errors.[Real-World Example](./docs/real-world-example.md)


## Overview

The module consists of two main components:
- **VM Creation Module**: Creates Ubuntu 24 virtual machines on Harvester
- **Ansible Module**: Optionally runs Ansible playbooks for post-provisioning configuration

## Features

- Automated VM provisioning on Harvester infrastructure
- Flexible VM configuration (CPU, memory, disk, network)
- Optional Ansible integration for configuration management
- Support for SSH key-based authentication
- Container/Docker runtime support via Ansible
- Jenkins CI/CD pipeline integration
- Batch VM creation capabilities
- Auto-generated Terraform configurations for CI/CD
- Examples and helper scripts included

## Directory Structure

```
terraform-harvester/
├── modules/
│   ├── create_vm/       # VM creation module
│   └── ansible/         # Ansible integration module
├── ansible/             # Ansible playbooks and inventory
├── examples/            # Usage examples and helper scripts
│   └── cicd/           # CI/CD automation scripts
├── scripts/             # Utility scripts
├── jenkins/             # Jenkins pipeline configurations
├── main.tf              # Main Terraform configuration
├── variables.tf         # Variable definitions
├── outputs.tf           # Output definitions
└── null_resources.tf    # Null resource definitions
```

## Requirements

- Terraform >= 1.0
- Harvester provider configured
- SSH key for VM authentication (if using Ansible)
- Ansible installed locally (if using Ansible module)

## Usage

### Basic VM Creation

```hcl
module "ubuntu24" {
  source          = "./modules/create_vm"
  vm_name         = "my-ubuntu-vm"
  vm_namespace    = "default"
  vm_description  = "Ubuntu 24 VM"
  vm_cpu          = 2
  vm_memory       = "4Gi"
  vm_disk_size    = "20Gi"
  vm_network_name = "harvester-mgmt"
}
```

### VM Creation with Ansible Configuration

```hcl
module "ubuntu24" {
  source          = "./modules/create_vm"
  vm_name         = var.vm_name
  vm_namespace    = var.vm_namespace
  vm_description  = var.vm_description
  vm_cpu          = var.vm_cpu
  vm_memory       = var.vm_memory
  vm_disk_size    = var.vm_disk_size
  vm_network_name = var.vm_network_name
}

module "ansible" {
  source                 = "./modules/ansible"
  vm_ip_address          = module.ubuntu24.ip_address
  vm_id                  = module.ubuntu24.vm_id
  vm_name                = module.ubuntu24.hostname
  vm_ssh_key             = var.vm_ssh_key
  ansible_playbook_path  = "${path.module}/ansible/linux-playbook.yml"
  ansible_inventory_path = "${path.module}/ansible/inventory.ini"
  run_ansible            = var.run_ansible

  depends_on = [
    module.ubuntu24
  ]
}
```

### VM with Container Support

```hcl
module "container_vm" {
  source             = "./"
  vm_name            = "container-vm"
  vm_namespace       = "development"
  vm_description     = "VM with container support"
  vm_cpu             = 4
  vm_memory          = "8Gi"
  vm_disk_size       = "40Gi"
  vm_network_name    = "edge/vm-network"
  vm_ssh_key         = "./ansible/demo-key"
  run_ansible        = true
  ansible_extra_vars = {
    enable_container = true
  }
}
```

## Variables

| Variable | Description | Type | Default | Required |
|----------|-------------|------|---------|----------|
| `vm_name` | Name of the virtual machine | string | - | yes |
| `vm_namespace` | Namespace of the virtual machine | string | - | yes |
| `vm_description` | Description of the virtual machine | string | - | yes |
| `vm_cpu` | Number of CPUs for the VM | number | - | yes |
| `vm_memory` | Memory allocation for the VM (e.g., "4Gi") | string | - | yes |
| `vm_disk_size` | Disk size for the VM (e.g., "20Gi") | string | - | yes |
| `vm_network_name` | Network name for the VM | string | "harvester-mgmt" | no |
| `run_ansible` | Whether to run Ansible playbook after VM creation | bool | false | no |
| `vm_ssh_key` | Path to SSH private key for VM authentication | string | "" | no |
| `ansible_extra_vars` | Additional variables to pass to Ansible playbook | map(any) | {} | no |

## Outputs

The module provides outputs including:
- VM IP address
- VM ID
- VM hostname

## Examples

The `examples/` directory contains:
- `create_vm.sh` - Script for creating a single VM
- `create_multiple_vms.sh` - Script for creating multiple VMs
- Sample Terraform configurations

### CI/CD Examples

The `examples/cicd/` directory contains specialized scripts for CI/CD automation:
- **create_vm_ci_cd.sh**: Automated VM creation script for CI/CD pipelines
- **create_multiple_vms.sh**: Batch VM creation for CI/CD environments
- **provider.tf**: Pre-configured provider settings for CI/CD
- Auto-generated Terraform configurations for deployed VMs

### Creating a VM

```bash
cd examples/
./create_vm.sh
```

### CI/CD VM Creation

```bash
cd examples/cicd/
./create_vm_ci_cd.sh --vm-name my-vm --namespace development
```

## Helper Scripts

- **create_vm.sh**: Interactive script for VM creation with customizable parameters
- **create_multiple_vms.sh**: Batch VM creation script
- **create_vm_ci_cd.sh**: CI/CD-optimized VM creation with automated configuration generation

## Development

### Pre-commit Hooks

This repository uses pre-commit hooks for code quality checks. Configuration is in `.pre-commit-config.yaml`.

### Secrets Management

Secrets baseline is maintained in `.secrets.baseline` for security scanning.

## Jenkins Integration

The module includes a comprehensive Jenkins pipeline (`Jenkinsfile.deploy`) for automated VM deployment with the following features:

### Pipeline Parameters

- **VM_NAME**: Name of the VM to create
- **VM_NAMESPACE**: Target namespace (development, edge, staging, production)
- **DISK_SIZE**: Disk size options (20Gi, 40Gi, 80Gi, 100Gi)
- **CPU**: CPU cores (2, 4, 8)
- **MEMORY**: Memory allocation (4Gi, 8Gi, 16Gi)
- **RUN_ANSIBLE**: Enable Ansible configuration
- **INSTALL_DOCKER**: Install Docker/container runtime

### Pipeline Stages

1. **Checkout**: Retrieves source code
2. **Setup Kubeconfig**: Configures Kubernetes access
3. **Copy Private Key**: Sets up SSH keys for VM access
4. **Create VM**: Executes VM creation with specified parameters
5. **Get VM Info**: Retrieves and displays VM information

### Jenkins Configuration Requirements

- Credentials:
  - `harvester-kubeconfig`: Kubernetes configuration file
  - `demo-key`: SSH private key for VM access
- Terraform version: 1.5.0 (configurable)

## Contributing

1. Create a feature branch from `main`
2. Make your changes
3. Run pre-commit checks
4. Submit a pull request



## Support
For support, open an issue on GitHub

![Terraform](https://img.shields.io/badge/Terraform-1.5-blue)
![License](https://img.shields.io/badge/license-MIT-green)
