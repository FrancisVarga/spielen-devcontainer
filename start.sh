#!/bin/bash

# Exit on any error for debugging
set -e

echo "Starting container initialization..."

# Ensure SSH host keys exist
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    echo "Generating SSH host keys..."
    ssh-keygen -A
fi

# Create /var/run/sshd directory if it doesn't exist
mkdir -p /var/run/sshd

# Set up SSH keys for the developer user (if script exists)
if [ -f /setup-ssh-keys-runtime.sh ]; then
    echo "Setting up SSH keys..."
    /setup-ssh-keys-runtime.sh
fi

# Start SSH service in daemon mode (non-blocking)
echo "Starting SSH daemon..."
if /usr/sbin/sshd -D &
then
    echo "SSH daemon started successfully"
    SSH_PID=$!
else
    echo "Failed to start SSH daemon"
    exit 1
fi

echo "Container initialization complete. Container will stay running..."

# Keep the container running by waiting for the SSH daemon
wait $SSH_PID
