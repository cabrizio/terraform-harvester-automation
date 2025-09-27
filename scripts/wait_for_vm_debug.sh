#!/bin/bash

VM_IP="$1"
USERNAME="$2"
PASSWORD="$3"

echo "Waiting for VM to be ready..."
echo "Target: $USERNAME@$VM_IP"

# Function to check SSH port
check_ssh_port() {
    nc -z -w 5 "$1" 22 2>/dev/null
}

# Function to try SSH connection with timeout using background process
try_ssh_with_timeout() {
    local timeout_duration=10
    local temp_file=$(mktemp)

    # Run SSH in background and capture PID
    sshpass -p "$PASSWORD" ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$USERNAME@$VM_IP" 'echo "SSH connection successful"' > "$temp_file" 2>&1 &
    local ssh_pid=$!

    # Wait for the specified timeout
    local count=0
    while [ $count -lt $timeout_duration ]; do
        if ! kill -0 $ssh_pid 2>/dev/null; then
            # Process finished
            wait $ssh_pid
            local exit_code=$?
            if [ $exit_code -eq 0 ] && grep -q "SSH connection successful" "$temp_file"; then
                rm -f "$temp_file"
                return 0
            fi
            rm -f "$temp_file"
            return $exit_code
        fi
        sleep 1
        count=$((count + 1))
    done

    # Timeout reached, kill the process
    kill $ssh_pid 2>/dev/null
    wait $ssh_pid 2>/dev/null
    rm -f "$temp_file"
    return 124  # timeout exit code
}

# First, wait for SSH port to be accessible
echo "Waiting for SSH port to be accessible..."
port_attempts=0
max_port_attempts=60

while [ $port_attempts -lt $max_port_attempts ]; do
    port_attempts=$((port_attempts + 1))
    echo "Port check attempt $port_attempts/$max_port_attempts..."

    if check_ssh_port "$VM_IP"; then
        echo "✓ SSH port 22 is now accessible!"
        break
    fi

    if [ $port_attempts -eq $max_port_attempts ]; then
        echo "✗ SSH port never became accessible"
        exit 1
    fi

    echo "SSH port not ready, retrying in 5 seconds..."
    sleep 5
done

# Now try SSH connections
echo "SSH port is accessible, trying connections..."
for i in $(seq 1 30); do
    echo "SSH attempt $i/30..."

    if try_ssh_with_timeout; then
        echo "VM is ready!"
        exit 0
    fi

    echo "SSH attempt $i failed, retrying in 10 seconds..."
    sleep 10
done

echo "VM failed to become ready after SSH attempts"
exit 1
