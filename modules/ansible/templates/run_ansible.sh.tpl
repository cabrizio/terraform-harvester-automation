#!/bin/bash
# Generated Ansible execution script
# Target VM: ${vm_ip}
# User: ${ansible_user}

set -e

SCRIPT_DIR="$(cd "$(dirname "${"$"}{BASH_SOURCE[0]}")" && pwd)"
INVENTORY_PATH="${inventory_path}"
PLAYBOOK_PATH="${playbook_path}"
ANSIBLE_USER="${ansible_user}"
VM_IP="${vm_ip}"

echo "=============================================="
echo "Ansible Playbook Execution Script"
echo "=============================================="
echo "VM IP: $VM_IP"
echo "User: $ANSIBLE_USER"
echo "Inventory: $INVENTORY_PATH"
echo "Playbook: $PLAYBOOK_PATH"
echo "Script Directory: $SCRIPT_DIR"
echo ""

# Change to the correct directory
cd "$(dirname "$PLAYBOOK_PATH")"

# Build the ansible-playbook command
ANSIBLE_CMD="ansible-playbook"
ANSIBLE_CMD="$ANSIBLE_CMD -i $INVENTORY_PATH"
ANSIBLE_CMD="$ANSIBLE_CMD $(basename $PLAYBOOK_PATH)"
ANSIBLE_CMD="$ANSIBLE_CMD --ask-pass"
ANSIBLE_CMD="$ANSIBLE_CMD --become"
ANSIBLE_CMD="$ANSIBLE_CMD --ask-become-pass"

# Add extra variables if any
%{if length(extra_vars) > 0}
EXTRA_VARS=""
%{for key, value in extra_vars}
EXTRA_VARS="$EXTRA_VARS ${key}='${value}'"
%{endfor}
if [ -n "$EXTRA_VARS" ]; then
    ANSIBLE_CMD="$ANSIBLE_CMD -e \"$EXTRA_VARS\""
fi
%{endif}

# Add tags if specified
%{if tags != ""}
ANSIBLE_CMD="$ANSIBLE_CMD --tags=${tags}"
%{endif}

# Add skip tags if specified
%{if skip_tags != ""}
ANSIBLE_CMD="$ANSIBLE_CMD --skip-tags=${skip_tags}"
%{endif}

# Add verbosity for debugging
ANSIBLE_CMD="$ANSIBLE_CMD -v"

echo "Command to execute:"
echo "$ANSIBLE_CMD"
echo ""

# Set environment variables
export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_REMOTE_USER=$ANSIBLE_USER
export ANSIBLE_BECOME=yes
export ANSIBLE_BECOME_METHOD=sudo

# Test connectivity first
echo "Testing connectivity to $VM_IP..."
if ! ansible all -i "$INVENTORY_PATH" -m ping --ask-pass; then
    echo "❌ Connectivity test failed!"
    echo "Please check:"
    echo "1. VM is running and accessible"
    echo "2. SSH service is running on the VM"
    echo "3. Firewall allows SSH connections"
    echo "4. Correct username and password"
    exit 1
fi

echo "✅ Connectivity test passed!"
echo ""

# Execute the playbook
echo "Executing Ansible playbook..."
eval $ANSIBLE_CMD

echo ""
echo "✅ Ansible playbook execution completed!"
