# Docker Container Scripts

This directory contains modular shell scripts used by the Dockerfile for easier maintenance and organization.

## Script Files

### `start.sh`
**Purpose**: Container startup script
- Starts the SSH service
- Switches to the developer user
- Keeps the container running

**Usage**: Automatically executed when the container starts via `CMD ["/start.sh"]`

### `setup-ssh-keys.sh`
**Purpose**: SSH key configuration
- Creates SSH directory with proper permissions
- Fetches public keys from GitHub API for user `FrancisVarga`
- Sets up authorized_keys file for passwordless SSH authentication

**Usage**: Executed during container build as the developer user

### `install-dev-tools.sh`
**Purpose**: Development tools installation
- Installs Python versions (3.11.7, 3.12.1) via pyenv
- Installs Node.js (LTS and latest) via nvm
- Installs Python development tools (pip, poetry, black, etc.)
- Installs Node.js development tools (yarn, typescript, eslint, etc.)
- Installs Rust and Cargo
- Installs Go programming language

**Usage**: Executed during container build as the developer user

### `setup-shell.sh`
**Purpose**: Shell environment configuration
- Sets up useful bash aliases (ll, la, l, etc.)
- Configures git global settings
- Sets up shell environment for development

**Usage**: Executed during container build as the developer user

## Benefits of Modular Scripts

1. **Maintainability**: Each script has a single responsibility, making them easier to understand and modify
2. **Reusability**: Scripts can be used independently or in other contexts
3. **Debugging**: Easier to test and debug individual components
4. **Version Control**: Changes to specific functionality are isolated to relevant scripts
5. **Readability**: The Dockerfile is cleaner and more focused on the build process

## Modifying Scripts

To modify any functionality:

1. Edit the relevant script file
2. Rebuild the Docker image to apply changes
3. The scripts are copied into the container during build and then removed after execution

## Script Execution Order

During Docker build, scripts are executed in this order:

1. System packages and SSH configuration (inline in Dockerfile)
2. `install-dev-tools.sh` - Development tools installation
3. System tools installation (Docker CLI, GitHub CLI, etc.)
4. `setup-shell.sh` - Shell configuration
5. `setup-ssh-keys.sh` - SSH keys setup
6. `start.sh` - Used at container runtime

## Error Handling

- `install-dev-tools.sh` uses `set -e` to exit on any error
- All scripts include echo statements for progress tracking
- Scripts are removed after execution to keep the container clean

## Customization

To customize for different users or requirements:

1. **SSH Keys**: Modify the GitHub username in `setup-ssh-keys.sh`
2. **Development Tools**: Add/remove tools in `install-dev-tools.sh`
3. **Shell Configuration**: Modify aliases and git config in `setup-shell.sh`
4. **Startup Behavior**: Modify `start.sh` for different startup requirements
