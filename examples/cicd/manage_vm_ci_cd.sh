#!/bin/bash
set -e

# VM Creation Wrapper Script
# Usage: ./create_vm_ci_cd.sh <vm_name> <namespace> <disk_size> [options]

# Default values
DEFAULT_CPU=2
DEFAULT_DISK_SIZE="20Gi"
DEFAULT_MEMORY="4Gi"
DEFAULT_NETWORK="development/vm-network"
DEFAULT_SSH_KEY="../../ansible/demo-key"
DEFAULT_RUN_ANSIBLE=false
DEFAULT_RUN_ANSIBLE_CONTAINER="{enable_container=false}"

# Function to show usage
usage() {
    echo "Usage: $0 <vm_name> <namespace> <disk_size> [options]"
    echo ""
    echo "Required parameters:"
    echo "  vm_name     - Name of the VM to create"
    echo "  namespace   - Kubernetes namespace for the VM"
    echo "  disk_size   - Disk size (e.g., 20Gi, 40Gi, 100Gi)"
    echo ""
    echo "Optional parameters:"
    echo "  --cpu <cores>           - Number of CPU cores (default: $DEFAULT_CPU)"
    echo "  --memory <size>         - Memory size (default: $DEFAULT_MEMORY)"
    echo "  --network <name>        - Network name (default: $DEFAULT_NETWORK)"
    echo "  --ssh-key <path>        - SSH key path (default: $DEFAULT_SSH_KEY)"
    echo "  --run-ansible           - Run Ansible after VM creation (default: false)"
    echo "  --run-ansible           - Run Ansible Container playbook after VM creation (default: false)"
    echo "  --help                  - Show this help message"
    echo ""
    echo "Ansible Feature Flags (use with --run-ansible):"
    echo "  --container             - Enable container setup (sets enable_container=true)"
    echo ""
    echo "Examples:"
    echo "  $0 web-server production 40Gi"
    echo "  $0 db-server staging 100Gi --cpu 4 --memory 8Gi --run-ansible"
    echo "  $0 db-server staging 100Gi --cpu 4 --memory 8Gi --run-ansible --container"
    echo "  $0 test-vm development 20Gi --cpu 1 --memory 2Gi 'common,security'"
    exit 1
}

# Parse command line arguments
if [ $# -lt 2 ]; then
    echo "Error: Missing required parameters"
    usage
fi

VM_NAME="$1"
VM_NAMESPACE="$2"
shift 2

# Set defaults
VM_CPU="$DEFAULT_CPU"
VM_MEMORY="$DEFAULT_MEMORY"
VM_DISK_SIZE="$DEFAULT_DISK_SIZE"
VM_NETWORK="$DEFAULT_NETWORK"
VM_SSH_KEY="$DEFAULT_SSH_KEY"
RUN_ANSIBLE="$DEFAULT_RUN_ANSIBLE"
ENABLE_CONTAINER="$DEFAULT_RUN_ANSIBLE_CONTAINER"

# Parse optional arguments
while [ $# -gt 0 ]; do
    case $1 in
        --cpu)
            VM_CPU="$2"
            shift 2
            ;;
        --memory)
            VM_MEMORY="$2"
            shift 2
            ;;
        --disk-size)
            VM_DISK_SIZE="$2"
            shift 2
            ;;
        --network)
            VM_NETWORK="$2"
            shift 2
            ;;
        --ssh-key)
            VM_SSH_KEY="$2"
            shift 2
            ;;
        --run-ansible)
            RUN_ANSIBLE="true"
            shift
            ;;
        --container)
            ENABLE_CONTAINER={enable_container=true}
            shift
            ;;
        --destroy)
            echo "Destroying VM $VM_NAME in namespace $VM_NAMESPACE"
            terraform destroy --target="module.$VM_NAME" -auto-approve
            exit 0
            ;;
        --help)
            usage
            ;;
        *)
            echo "Error: Unknown option $1"
            usage
            ;;
    esac
done

# Auto-generate description
VM_DESCRIPTION="VM $VM_NAME in $VM_NAMESPACE namespace"

# Validate inputs
if [[ ! "$VM_DISK_SIZE" =~ ^[0-9]+Gi$ ]]; then
    echo "Error: Disk size must be in format like '20Gi', '40Gi', etc."
    exit 1
fi

if [[ ! "$VM_MEMORY" =~ ^[0-9]+Gi$ ]]; then
    echo "Error: Memory size must be in format like '2Gi', '4Gi', etc."
    exit 1
fi

if ! [[ "$VM_CPU" =~ ^[0-9]+$ ]]; then
    echo "Error: CPU must be a number"
    exit 1
fi

# Check if SSH key exists
if [ ! -f "$VM_SSH_KEY" ]; then
    echo "Error: SSH key not found at $VM_SSH_KEY"
    exit 1
fi

echo "=== VM Creation Configuration ==="
echo "VM Name: $VM_NAME"
echo "Namespace: $VM_NAMESPACE"
echo "CPU Cores: $VM_CPU"
echo "Memory: $VM_MEMORY"
echo "Disk Size: $VM_DISK_SIZE"
echo "Network: $VM_NETWORK"
echo "SSH Key: $VM_SSH_KEY"
echo "Description: $VM_DESCRIPTION"
echo "Run Ansible: $RUN_ANSIBLE"
echo "Enable Container: $ENABLE_CONTAINER"
echo "================================="

# Create Terraform main.tf if not exists
if [ ! -f "./main.tf" ]; then
    MAIN_TF_FILE="main-${VM_NAME}.tf"
    cat > "$MAIN_TF_FILE" << EOF
    # Auto-generated main.tf for VM: $VM_NAME
    module "${VM_NAME}" {
      source          = "../../"
      vm_name         = "$VM_NAME"
      vm_namespace    = "$VM_NAMESPACE"
      vm_description  = "$VM_DESCRIPTION"
      vm_cpu          = $VM_CPU
      vm_memory       = "$VM_MEMORY"
      vm_disk_size    = "$VM_DISK_SIZE"
      vm_network_name = "$VM_NETWORK"
      vm_ssh_key      = "$VM_SSH_KEY"
      run_ansible     = $RUN_ANSIBLE
      ansible_extra_vars = $ENABLE_CONTAINER
    }

    output "${VM_NAME}_output" {
      value = module.${VM_NAME}
    }
EOF
else
  echo "Using existing main.tf"
fi

# Execute Terraform
echo "Executing Terraform..."
terraform init -upgrade
terraform plan

terraform apply --target="module.$VM_NAME" -auto-approve

if [ $? -eq 0 ]; then
    echo ""
    echo "=== VM Creation Completed Successfully ==="
    echo "VM Name: $VM_NAME"
    echo "Namespace: $VM_NAMESPACE"

    # Get VM IP address from Terraform output
    echo "Getting VM IP address from Terraform state..."
    if command -v jq >/dev/null 2>&1; then
        # Try multiple JSON paths to find the IP (properly escape VM name with hyphens)
        VM_IP=$(terraform output -json | jq -r ".[\"${VM_NAME}_output\"].value.all.ip_address // .all.value.all.ip_address // .all.value.ip_address // empty" 2>/dev/null)

        # If still empty, try to find any output with ip_address
        if [ -z "$VM_IP" ]; then
            VM_IP=$(terraform output -json | jq -r '.[] | select(.value.all.ip_address) | .value.all.ip_address' 2>/dev/null | head -1)
        fi
    fi

    if [ -z "$VM_IP" ]; then
        VM_IP="Not available yet"
    fi
    echo "VM IP Address: $VM_IP"


    if [ "$RUN_ANSIBLE" = "true" ] && [ "$VM_IP" != "Not available yet" ]; then
        echo ""
        if [ "$ENABLE_CONTAINER" = "true" ]; then
            echo "Ansible was executed with container setup enabled (enable_container=true)"
        else
            echo "Ansible was executed with default configuration"
        fi
    fi

    echo ""
    echo "SSH Access:"
    echo "  ssh -i $VM_SSH_KEY ansible@$VM_IP"
    echo ""
    if [ "$ENABLE_CONTAINER" = "true" ]; then
        echo "Manual Ansible with container setup:"
        echo "  ansible-playbook -i inventory.ini linux-playbook.yml --private-key=$VM_SSH_KEY -e \"enable_container=true\""
        echo ""
    fi
    echo "Cleanup:"
    echo "  terraform destroy --target=module.$VM_NAME"
    echo "============================================="

else
    echo "Error: Terraform apply failed"
    exit 1
fi
