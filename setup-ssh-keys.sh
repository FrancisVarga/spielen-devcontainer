#!/bin/bash

# Setup SSH keys for GitHub authentication in Codespaces
# This script handles both generating new keys and configuring existing ones

set -e

USER_EMAIL="francis.varga@gmail.com"
USER_NAME="FrancisVarga"
SSH_KEY_FILE="$HOME/.ssh/id_ed25519"

echo "🔑 Setting up SSH keys for GitHub authentication..."

# Create SSH directory with proper permissions
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Function to generate new SSH key
generate_ssh_key() {
    echo "📝 Generating new SSH key..."
    ssh-keygen -t ed25519 -C "$USER_EMAIL" -f "$SSH_KEY_FILE" -N ""
    echo "✅ SSH key generated successfully!"
}

# Function to configure SSH
configure_ssh() {
    echo "⚙️  Configuring SSH client..."
    
    # Create SSH config if it doesn't exist
    cat > ~/.ssh/config << SSHEOF
# GitHub configuration
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
    AddKeysToAgent yes

# Default configuration for all hosts
Host *
    AddKeysToAgent yes
    UseKeychain yes
    IdentitiesOnly yes
SSHEOF

    chmod 600 ~/.ssh/config
    echo "✅ SSH config created successfully!"
}

# Function to start SSH agent and add key
setup_ssh_agent() {
    echo "🔧 Setting up SSH agent..."
    
    # Start SSH agent if not running
    if [ -z "$SSH_AUTH_SOCK" ]; then
        eval "$(ssh-agent -s)"
        echo "✅ SSH agent started"
    else
        echo "✅ SSH agent already running"
    fi
    
    # Add key to SSH agent
    if [ -f "$SSH_KEY_FILE" ]; then
        ssh-add "$SSH_KEY_FILE" 2>/dev/null || echo "Key already added to agent"
        echo "✅ SSH key added to agent"
    fi
}

# Function to test GitHub connection
test_github_connection() {
    echo "🧪 Testing GitHub SSH connection..."
    if ssh -T git@github.com -o StrictHostKeyChecking=no 2>&1 | grep -q "successfully authenticated"; then
        echo "✅ GitHub SSH connection successful!"
        return 0
    else
        echo "❌ GitHub SSH connection failed. You need to add the public key to GitHub."
        return 1
    fi
}

# Function to display public key
show_public_key() {
    if [ -f "$SSH_KEY_FILE.pub" ]; then
        echo ""
        echo "📋 Your public key (copy this to GitHub):"
        echo "----------------------------------------"
        cat "$SSH_KEY_FILE.pub"
        echo "----------------------------------------"
        echo ""
        echo "📖 To add this key to GitHub:"
        echo "1. Go to https://github.com/settings/ssh/new"
        echo "2. Paste the key above into the 'Key' field"
        echo "3. Give it a title like 'Codespace - $(date +%Y-%m-%d)'"
        echo "4. Click 'Add SSH key'"
        echo ""
    fi
}

# Function to configure git for SSH
configure_git_for_ssh() {
    echo "🔧 Configuring git for SSH..."
    
    # Set git user info if not already set
    if [ -z "$(git config --global user.name)" ]; then
        git config --global user.name "$USER_NAME"
        echo "✅ Git user name set to: $USER_NAME"
    fi
    
    if [ -z "$(git config --global user.email)" ]; then
        git config --global user.email "$USER_EMAIL"
        echo "✅ Git user email set to: $USER_EMAIL"
    fi
    
    # Check if current repo is using HTTPS and offer to switch
    if git remote get-url origin 2>/dev/null | grep -q "https://github.com"; then
        echo "🔄 Current repository is using HTTPS. Converting to SSH..."
        REPO_URL=$(git remote get-url origin)
        SSH_URL=$(echo "$REPO_URL" | sed 's|https://github.com/|git@github.com:|')
        git remote set-url origin "$SSH_URL"
        echo "✅ Repository remote updated to use SSH: $SSH_URL"
    fi
}

# Main execution
main() {
    echo "🚀 Starting SSH key setup for GitHub Codespaces..."
    echo "User: $USER_NAME"
    echo "Email: $USER_EMAIL"
    echo ""
    
    # Generate SSH key if it doesn't exist
    if [ ! -f "$SSH_KEY_FILE" ]; then
        generate_ssh_key
    else
        echo "✅ SSH key already exists at $SSH_KEY_FILE"
    fi
    
    # Configure SSH
    configure_ssh
    
    # Setup SSH agent
    setup_ssh_agent
    
    # Configure git
    configure_git_for_ssh
    
    # Show public key for GitHub
    show_public_key
    
    # Test connection
    if ! test_github_connection; then
        echo ""
        echo "⚠️  Manual action required:"
        echo "Please add the public key above to your GitHub account, then run:"
        echo "ssh -T git@github.com"
        echo "to verify the connection."
    fi
    
    echo ""
    echo "🎉 SSH key setup completed!"
}

# Run main function
main
