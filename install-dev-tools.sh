# Verify pyenv installation
if ! command -v pyenv &> /dev/null; then
    echo "pyenv could not be found. Please ensure it is installed."
    exit 1
fi

# Verify nvm installation
if [ -z "$NVM_DIR" ] || [ ! -s "$NVM_DIR/nvm.sh" ]; then
    echo "nvm could not be found. Please ensure it is installed."
    exit 1
fi

# Source nvm
source "$NVM_DIR/nvm.sh"