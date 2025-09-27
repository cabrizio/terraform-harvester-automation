#!/bin/bash
set -e

# Ansible runner script with SSH key authentication
PLAYBOOK_PATH="$1"
INVENTORY_PATH="$2"
VM_IP="$3"
ANSIBLE_USER="$4"
SSH_PRIVATE_KEY="$5"
EXTRA_VARS="$6"
TAGS="$7"
SKIP_TAGS="$8"
# Usage function
usage() {
    echo "Usage: $0 <playbook_path> <inventory_path> <vm_ip> <ansible_user> [ssh_private_key] [tags] [skip_tags] [extra_vars_json]"
    echo ""
    echo "Parameters:"
    echo "  playbook_path    - Path to the Ansible playbook"
    echo "  inventory_path   - Path to the Ansible inventory"
    echo "  vm_ip           - Target VM IP address"
    echo "  ansible_user    - SSH user for connection"
    echo "  ssh_private_key - Path to SSH private key (optional, defaults to ~/.ssh/id_rsa)"
    echo "  tags            - Ansible tags to run (optional)"
    echo "  skip_tags       - Ansible tags to skip (optional)"
    echo "  extra_vars_json - Extra variables in JSON format (optional)"
    echo ""
    echo "Example:"
    echo "  $0 ansible/playbooks/setup-server.yml ansible/inventory 10.1.1.100 ansible ~/.ssh/vm_key 'setup,security' '' '{\"var1\":\"value1\"}'"
    exit 1
}

# Check required parameters
if [ $# -lt 4 ]; then
    usage
fi

# Set default SSH key if not provided
if [ -z "$SSH_PRIVATE_KEY" ] || [ "$SSH_PRIVATE_KEY" = "null" ]; then
    SSH_PRIVATE_KEY="$HOME/.ssh/id_rsa"
fi

# Validate required files exist
if [ ! -f "$PLAYBOOK_PATH" ]; then
    echo "Error: Playbook file not found: $PLAYBOOK_PATH"
    exit 1
fi

if [ ! -f "$INVENTORY_PATH" ]; then
    echo "Error: Inventory file not found: $INVENTORY_PATH"
    exit 1
fi

if [ ! -f "$SSH_PRIVATE_KEY" ]; then
    echo "Error: SSH private key not found: $SSH_PRIVATE_KEY"
    echo "Please ensure your SSH key exists or specify a different key path"
    exit 1
fi

echo "=== Ansible Playbook Runner ==="
echo "Playbook: $PLAYBOOK_PATH"
echo "Inventory: $INVENTORY_PATH"
echo "Target VM: $VM_IP"
echo "User: $ANSIBLE_USER"
echo "SSH Key: $SSH_PRIVATE_KEY"
echo "Extra Vars: ${EXTRA_VARS:-none}"
echo "Tags: ${TAGS:-none}"
echo "Skip Tags: ${SKIP_TAGS:-none}"
echo "Timestamp: $(date)"

# Test SSH connection first
echo ""
echo "Testing SSH connection..."
if ssh -i "$SSH_PRIVATE_KEY" -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$ANSIBLE_USER@$VM_IP" 'echo "SSH connection successful"' >/dev/null 2>&1; then
    echo "✓ SSH connection test successful"
else
    echo "✗ SSH connection failed"
    echo "Please ensure:"
    echo "  1. VM is running and accessible at $VM_IP"
    echo "  2. SSH key $SSH_PRIVATE_KEY has correct permissions (600)"
    echo "  3. Public key is installed on the target VM"
    echo "  4. User $ANSIBLE_USER exists on the target VM"
    exit 1
fi

# Build ansible-playbook command
ANSIBLE_CMD="ansible-playbook"
ANSIBLE_CMD="$ANSIBLE_CMD -i $INVENTORY_PATH"
ANSIBLE_CMD="$ANSIBLE_CMD $PLAYBOOK_PATH"

# Add SSH private key
ANSIBLE_CMD="$ANSIBLE_CMD --private-key=$SSH_PRIVATE_KEY"

# Add tags if provided
if [ -n "$TAGS" ] && [ "$TAGS" != "null" ]; then
    echo "Running with tags: $TAGS"
    ANSIBLE_CMD="$ANSIBLE_CMD --tags=$TAGS"
fi

# Add skip tags if provided
if [ -n "$SKIP_TAGS" ] && [ "$SKIP_TAGS" != "null" ]; then
    echo "Skipping tags: $SKIP_TAGS"
    ANSIBLE_CMD="$ANSIBLE_CMD --skip-tags=$SKIP_TAGS"
fi

# Parse and add extra vars if provided (JSON format)
if [ -n "$EXTRA_VARS" ] && [ "$EXTRA_VARS" != "{}" ] && [ "$EXTRA_VARS" != "null" ]; then
    echo "Adding extra vars: $EXTRA_VARS"
    ANSIBLE_CMD="$ANSIBLE_CMD -e '$EXTRA_VARS'"
fi

# Set environment variables
export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_REMOTE_USER="$ANSIBLE_USER"
export ANSIBLE_BECOME=yes
export ANSIBLE_BECOME_METHOD=sudo
export ANSIBLE_TIMEOUT=30
export ANSIBLE_GATHER_TIMEOUT=30
export ANSIBLE_CONFIG="$ANSIBLE_DIR/ansible.cfg"
export ANSIBLE_PRIVATE_KEY_FILE="$SSH_PRIVATE_KEY"

echo ""
echo "Environment:"
echo "  ANSIBLE_CONFIG: $ANSIBLE_CONFIG"
echo "  ANSIBLE_REMOTE_USER: $ANSIBLE_REMOTE_USER"
echo "  ANSIBLE_PRIVATE_KEY_FILE: $ANSIBLE_PRIVATE_KEY_FILE"
echo "  ANSIBLE_HOST_KEY_CHECKING: $ANSIBLE_HOST_KEY_CHECKING"

echo ""
echo "Executing: $ANSIBLE_CMD"
echo ""

# Execute the command
eval "$ANSIBLE_CMD"

echo ""
echo "=== Ansible playbook execution completed successfully! ==="
