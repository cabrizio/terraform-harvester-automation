#!/bin/bash
set -e

# VM disk resize handler script
VM_NAME="$1"
VM_NAMESPACE="$2"
VM_DISK_SIZE="$3"

if [ $# -ne 3 ]; then
    echo "Usage: $0 <vm_name> <vm_namespace>"
    echo "Example: $0 ubuntu24 terraform-namespace"
    exit 1
fi

echo "=== VM Disk Resize Handler ==="
echo "VM: $VM_NAME"
echo "Namespace: $VM_NAMESPACE"
echo "=============================="

# Function to wait with timeout (macOS compatible)
wait_with_timeout() {
    local max_attempts=$1
    local check_command=$2
    local description=$3

    local attempt=0
    while [ $attempt -lt $max_attempts ]; do
        if eval "$check_command" >/dev/null 2>&1; then
            echo "$description completed successfully"
            return 0
        fi
        echo "$description... (attempt $((attempt+1))/$max_attempts)"
        sleep 5
        attempt=$((attempt+1))
    done

    echo "Warning: $description timed out after $max_attempts attempts"
    return 1
}

# Step 1: Stop the VM
echo "Step 1: Stopping VM $VM_NAME..."
kubectl patch vm "$VM_NAME" -n "$VM_NAMESPACE" --type merge -p '{"spec":{"runStrategy":"Halted"}}'

# Wait for VM to stop
echo "Waiting for VM to stop..."
wait_with_timeout 60 \
    "kubectl get vm $VM_NAME -n $VM_NAMESPACE -o jsonpath='{.status.printableStatus}' | grep -v -E 'Running|Starting'" \
    "VM stop"

# Additional wait to ensure VM is completely stopped and Harvester is ready
echo "Waiting additional 20 seconds to ensure VM is completely stopped..."
sleep 20

echo "VM stopped successfully!"
