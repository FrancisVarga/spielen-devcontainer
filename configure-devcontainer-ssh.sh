#!/bin/bash

# Add SSH key setup to devcontainer for automatic configuration
# This ensures SSH keys are set up automatically in all future codespaces

DEVCONTAINER_FILE=".devcontainer/devcontainer.json"
SETUP_SCRIPT="setup-ssh-keys.sh"

echo "🔧 Configuring devcontainer for automatic SSH key setup..."

# Check if devcontainer.json exists
if [ ! -f "$DEVCONTAINER_FILE" ]; then
    echo "❌ No devcontainer.json found. Creating a basic one..."
    mkdir -p .devcontainer
    cat > "$DEVCONTAINER_FILE" << 'DEVEOF'
{
    "name": "Development Container",
    "image": "mcr.microsoft.com/devcontainers/universal:2",
    "features": {
        "ghcr.io/devcontainers/features/github-cli:1": {}
    },
    "postCreateCommand": "bash setup-ssh-keys.sh",
    "customizations": {
        "vscode": {
            "settings": {
                "git.enableCommitSigning": true
            }
        }
    }
}
DEVEOF
    echo "✅ Created basic devcontainer.json with SSH setup"
else
    echo "✅ Found existing devcontainer.json"
    
    # Check if postCreateCommand already exists
    if grep -q "postCreateCommand" "$DEVCONTAINER_FILE"; then
        echo "⚠️  postCreateCommand already exists in devcontainer.json"
        echo "   You may want to manually add 'bash setup-ssh-keys.sh' to it"
    else
        echo "📝 Adding postCreateCommand to existing devcontainer.json..."
        # This is a simple approach - for complex JSON, consider using jq
        sed -i 's/}$/,\n    "postCreateCommand": "bash setup-ssh-keys.sh"\n}/' "$DEVCONTAINER_FILE"
        echo "✅ Added SSH setup to devcontainer configuration"
    fi
fi

echo ""
echo "📖 Next steps:"
echo "1. Run './setup-ssh-keys.sh' to set up SSH keys for this codespace"
echo "2. Add the public key to your GitHub account"
echo "3. Future codespaces will automatically run the SSH setup script"
echo ""
