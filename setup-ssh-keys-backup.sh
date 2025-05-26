#!/bin/bash

# Setup SSH keys from GitHub for the developer user
# This script should be run as the developer user

# Create SSH directory with proper permissions
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Fetch public keys from GitHub and add to authorized_keys
echo "Fetching SSH keys from GitHub for user: FrancisVarga"
curl -s https://api.github.com/users/FrancisVarga/keys | jq -r '.[].key' > ~/.ssh/authorized_keys

# Set proper permissions for authorized_keys
chmod 600 ~/.ssh/authorized_keys

echo "SSH keys setup completed"
echo "Number of keys installed: $(wc -l < ~/.ssh/authorized_keys)"
