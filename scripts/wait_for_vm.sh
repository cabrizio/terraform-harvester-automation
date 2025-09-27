#!/bin/bash

VM_IP="$1"
USERNAME="$2"
SSH_KEY="$3"

echo "Waiting for VM to be ready..."
echo "Target: $USERNAME@$VM_IP"

# Function to check SSH port
check_ssh_port() {
    nc -z -w 5 "$1" 22 2>/dev/null
}

# First, wait for SSH port to be accessible
echo "Waiting for SSH port to be accessible..."
port_attempts=0
max_port_attempts=60

while [ $port_attempts -lt $max_port_attempts ]; do
    port_attempts=$((port_attempts + 1))

    if check_ssh_port "$VM_IP"; then
        echo "✓ SSH port 22 is accessible!"
        break
    fi

    if [ $port_attempts -eq $max_port_attempts ]; then
        echo "✗ SSH port never became accessible after $max_port_attempts attempts"
        exit 1
    fi

    if [ $((port_attempts % 10)) -eq 0 ]; then
        echo "SSH port check attempt $port_attempts/$max_port_attempts..."
    fi

    sleep 5
done

# Now try SSH connections
echo "Attempting SSH connections..."
for i in $(seq 1 30); do
    echo "SSH attempt $i/30..."

    if ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$SSH_KEY" "$USERNAME@$VM_IP" 'echo "SSH connection successful"' >/dev/null 2>&1; then
        echo "✓ VM is ready!"
        exit 0
    fi

    echo "SSH attempt $i failed, retrying in 10 seconds..."
    sleep 10
done

echo "✗ VM failed to become ready after SSH attempts"
exit 1
