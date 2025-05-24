#!/bin/bash

# Setup shell aliases and configurations for the developer user
# This script should be run as the developer user

echo "Setting up shell aliases and configurations..."

# Create useful aliases and functions
echo 'alias ll="ls -alF"' >> ~/.bashrc
echo 'alias la="ls -A"' >> ~/.bashrc
echo 'alias l="ls -CF"' >> ~/.bashrc
echo 'alias ..="cd .."' >> ~/.bashrc
echo 'alias ...="cd ../.."' >> ~/.bashrc
echo 'alias grep="grep --color=auto"' >> ~/.bashrc
echo 'alias fgrep="fgrep --color=auto"' >> ~/.bashrc
echo 'alias egrep="egrep --color=auto"' >> ~/.bashrc

# Set up git configuration template
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.editor vim

echo "Shell configuration completed!"
