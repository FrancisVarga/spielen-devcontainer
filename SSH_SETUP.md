# VSCode SSH Remote Setup for Docker Container

This Dockerfile has been configured to work with VSCode's Remote-SSH extension. Here's how to set it up:

## Prerequisites

- Docker installed on your system
- VSCode with the Remote-SSH extension installed

## Building and Running the Container

1. **Build the Docker image:**
   ```bash
   docker build -t dev-container .
   ```

2. **Run the container with SSH port mapping:**
   ```bash
   docker run -d -p 2222:22 -p 3000:3000 -p 8000:8000 --name dev-env dev-container
   ```

   This maps:
   - Port 2222 on host → Port 22 in container (SSH)
   - Port 3000 on host → Port 3000 in container (common dev server)
   - Port 8000 on host → Port 8000 in container (common dev server)

## Connecting with VSCode Remote-SSH

1. **Open VSCode and install Remote-SSH extension** (if not already installed)

2. **Add SSH configuration:**
   - Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
   - Type "Remote-SSH: Open SSH Configuration File"
   - Add the following configuration:

   ```
   Host dev-container
       HostName localhost
       Port 2222
       User developer
       PreferredAuthentications publickey,password
       PasswordAuthentication yes
   ```

3. **Connect to the container:**
   - Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
   - Type "Remote-SSH: Connect to Host"
   - Select "dev-container"
   - **SSH Key Authentication**: If your SSH keys are properly configured, it will connect automatically
   - **Password Fallback**: If key authentication fails, enter password: `password`

4. **Open your workspace:**
   - Once connected, you can open the `/home/developer/workspace` folder
   - All your development tools (Python, Node.js, Git, etc.) are pre-installed

## SSH Key Authentication

**Automatic GitHub SSH Key Integration**: This container automatically fetches and installs SSH public keys from the GitHub user `FrancisVarga` during the build process. This means:

- **Seamless Authentication**: If you have your SSH keys properly configured on your local machine and they match the keys in your GitHub account, you'll be able to connect without entering a password
- **Secure by Default**: SSH key authentication is more secure than password authentication
- **No Manual Setup**: The keys are automatically downloaded from `https://api.github.com/users/FrancisVarga/keys` and installed in the container

**How it works:**
1. During container build, the Dockerfile fetches your public keys from GitHub's API
2. These keys are added to the `~/.ssh/authorized_keys` file for the developer user
3. When you connect via SSH, your local private key is used for authentication
4. If key authentication fails, password authentication is available as a fallback

## Security Note

**Important:** The default password is set to `password` for convenience as a fallback authentication method. For production use, you should:

1. Change the password by modifying this line in the Dockerfile:
   ```dockerfile
   echo "$USER:your-secure-password" | chpasswd && \
   ```

2. Consider disabling password authentication entirely if you only want to use SSH keys:
   ```dockerfile
   sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
   ```

## Available Development Tools

The container includes:
- Python 3.11 and 3.12 (via pyenv)
- Node.js LTS and latest (via nvm)
- Git, Docker CLI, GitHub CLI
- Various development tools (pip, npm, yarn, etc.)
- Text editors (vim, nano, emacs)
- Build tools (gcc, make, cmake)

## Container Management

- **Stop the container:** `docker stop dev-env`
- **Start the container:** `docker start dev-env`
- **Remove the container:** `docker rm dev-env`
- **View container logs:** `docker logs dev-env`

## Troubleshooting

1. **Can't connect via SSH:**
   - Ensure the container is running: `docker ps`
   - Check if SSH service is running in container: `docker exec dev-env service ssh status`
   - Verify your SSH keys are loaded: `ssh-add -l`

2. **SSH Key Authentication Issues:**
   - Make sure your SSH agent is running: `eval $(ssh-agent)`
   - Add your keys to the agent: `ssh-add ~/.ssh/id_rsa` (or your key file)
   - Verify the keys match those in your GitHub account: `https://github.com/settings/keys`

3. **Permission issues:**
   - The developer user has sudo privileges without password
   - Use `sudo` for any system-level operations

4. **Port conflicts:**
   - If port 2222 is already in use, change it in the docker run command:
     ```bash
     docker run -d -p 2223:22 --name dev-env dev-container
     ```
   - Update the SSH config accordingly

## GitHub Integration Notes

- The container fetches SSH keys from the GitHub user `FrancisVarga` at build time
- If you need to update the keys, rebuild the container
- The GitHub API call is made during build, so ensure you have internet connectivity when building
- If the GitHub API is unavailable during build, the container will still work with password authentication
