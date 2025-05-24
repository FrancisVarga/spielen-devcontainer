#!/bin/bash

# Install development tools for the developer user
# This script should be run as the developer user

set -e  # Exit on any error

echo "Installing development tools..."

# Source bashrc to get environment variables
source ~/.bashrc

echo "Installing Python versions with pyenv..."
# Install Python 3.11 and 3.12
pyenv install 3.11.7
pyenv install 3.12.1
pyenv global 3.12.1

echo "Installing Node.js versions with nvm..."
# Install Node.js LTS and latest
source "$NVM_DIR/nvm.sh"
nvm install --lts
nvm install node
nvm use --lts
nvm alias default lts/*

echo "Installing Python development tools..."
# Install Python tools
pip install --upgrade pip
pip install pipenv poetry virtualenv black flake8 mypy pytest jupyter

echo "Installing Node.js development tools..."
# Install Node.js tools
source "$NVM_DIR/nvm.sh"
npm install -g yarn pnpm typescript ts-node eslint prettier nodemon pm2

echo "Installing Rust and Cargo..."
# Install Rust and Cargo
curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source ~/.cargo/env

echo "Installing Go..."
# Install Go
wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
rm go1.21.5.linux-amd64.tar.gz
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc

echo "Development tools installation completed!"
