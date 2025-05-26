#!/bin/bash

# Ensure SSH host keys exist
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -A
fi

# Create /var/run/sshd directory if it doesn't exist
mkdir -p /var/run/sshd

# Start SSH service in daemon mode (non-blocking)
/usr/sbin/sshd

# Keep the container running by tailing a log file or sleeping
# This ensures the container stays alive in detached mode
tail -f /dev/null
