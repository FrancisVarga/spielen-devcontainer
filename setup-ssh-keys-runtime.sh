#!/bin/bash

# Runtime SSH key setup script
# This script fetches SSH keys from GitHub and sets them up for the developer user

USER_HOME="/home/developer"
SSH_DIR="$USER_HOME/.ssh"
GITHUB_USER="FrancisVarga"

echo "Setting up SSH keys for user: $GITHUB_USER"

# Ensure SSH directory exists with correct permissions
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Try to fetch SSH keys from GitHub API
echo "Fetching SSH keys from GitHub..."
if curl -s --connect-timeout 10 --max-time 30 "https://api.github.com/users/$GITHUB_USER/keys" | jq -r '.[].key' > "$SSH_DIR/authorized_keys.tmp" 2>/dev/null; then
    # Check if we got any keys
    if [ -s "$SSH_DIR/authorized_keys.tmp" ]; then
        mv "$SSH_DIR/authorized_keys.tmp" "$SSH_DIR/authorized_keys"
        echo "✅ Successfully fetched SSH keys from GitHub"
    else
        echo "⚠️  No SSH keys found for user $GITHUB_USER"
        echo "# Add your SSH keys here" > "$SSH_DIR/authorized_keys"
    fi
else
    echo "⚠️  Failed to fetch SSH keys from GitHub (network issue or rate limit)"
    echo "# Add your SSH keys here" > "$SSH_DIR/authorized_keys"
fi

# Clean up temporary file if it exists
rm -f "$SSH_DIR/authorized_keys.tmp"

# Set correct permissions
chmod 600 "$SSH_DIR/authorized_keys"
chown -R developer:developer "$SSH_DIR"

echo "SSH key setup completed"
