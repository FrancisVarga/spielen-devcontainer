#!/bin/bash

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
/usr/sbin/sshd

echo "SSH daemon started successfully"
echo "Container initialization complete. Container will stay running..."

# Keep the container running with an infinite loop that checks SSH daemon
while true; do
    if ! pgrep sshd > /dev/null; then
        echo "SSH daemon stopped, restarting..."
        /usr/sbin/sshd
    fi
    sleep 30
done
