# Docker Container Fix

## Problem
The Docker container `dev-env` was immediately stopping when run with `docker run --rm -d dev-env` because the startup script wasn't keeping a long-running process active.

## Root Cause
The `start.sh` script was ending with `exec su - developer`, which switches to the developer user but doesn't maintain a persistent process. In detached mode (`-d`), containers need a long-running process to stay alive.

## Solution Applied
Modified `start.sh` to:
1. Start the SSH service
2. Use `exec tail -f /dev/null` to keep the container running indefinitely

This approach:
- Keeps the container alive in detached mode
- Allows SSH access to the container
- Uses minimal resources (tail on /dev/null)

## Commands to Fix (run these with appropriate Docker permissions)

1. **Rebuild the image:**
   ```bash
   docker build -t dev-env .
   ```

2. **Run the container:**
   ```bash
   docker run --rm -d dev-env
   ```

3. **Verify it's running:**
   ```bash
   docker ps
   ```

4. **Access the container via SSH or exec:**
   ```bash
   # Via exec (recommended for development)
   docker exec -it <container_id> bash
   
   # Via SSH (if you have SSH keys set up)
   ssh developer@<container_ip>
   ```

## Docker Permission Issue
If you're getting permission denied errors, you may need to:
1. Add your user to the docker group: `sudo usermod -aG docker $USER`
2. Log out and back in, or run: `newgrp docker`
3. Or run docker commands with sudo (not recommended for regular use)

## Alternative Start Script Options
If you need different behavior, here are other options for the final line in `start.sh`:

- **For interactive development:** `exec su - developer -c "bash"`
- **For service mode:** `exec tail -f /dev/null` (current solution)
- **For specific service:** `exec su - developer -c "your-service-command"`
