#!/bin/bash
set -e

# Multiple VM creation script
VM_COUNT="$1"
VM_BASE_NAME="$2"
VM_NAMESPACE="$3"

if [ $# -lt 3 ]; then
    echo "Usage: $0 <vm_count> <base_name> <namespace> [shared_options...]"
    echo "Example: $0 3 web-server production 40Gi --cpu 2 --memory 4Gi --run-ansible"
    exit 1
fi

shift 3  # Remove first 3 args, rest are shared options

echo "Creating $VM_COUNT VMs with base name: $VM_BASE_NAME"
echo "Namespace: $VM_NAMESPACE"
echo "Shared options: $*"

for i in $(seq 1 $VM_COUNT); do
    VM_NAME="${VM_BASE_NAME}-$(printf "%02d" $i)"
    echo ""
    echo "=== Creating VM $i/$VM_COUNT: $VM_NAME ==="

    # Call the existing create-vm.sh script
   ./manage_vm_helper.sh "$VM_NAME" "$VM_NAMESPACE" "$@"

    if [ $? -eq 0 ]; then
        echo "VM $VM_NAME created successfully"
    else
        echo "Failed to create VM $VM_NAME"
        exit 1
    fi
done

echo ""
echo "=== All VMs Created Successfully ==="
