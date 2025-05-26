# Developer Environment Docker Container

A comprehensive Docker-based development environment with pyenv, nvm, and essential developer tools pre-installed.

## Features

### Version Managers
- **pyenv**: Python version management (Python 3.11.7 and 3.12.1 pre-installed)
- **nvm**: Node.js version management (LTS and latest versions pre-installed)

### Programming Languages & Runtimes
- Python 3.11.7 and 3.12.1
- Node.js (LTS and latest)
- Go 1.21.5
- Rust (latest stable)



### Development Tools
- **Build Tools**: gcc, g++, make, cmake, build-essential
- **Version Control**: git, GitHub CLI (gh)
- **Editors**: vim, nano, emacs-nox
- **Package Managers**: pip, pipenv, poetry, npm, yarn, pnpm, cargo
- **Code Quality**: black, flake8, mypy, eslint, prettier
- **Testing**: pytest
- **Process Management**: pm2, supervisor
- **Containerization**: Docker CLI

### Python Tools
- pip, pipenv, poetry, virtualenv
- black (code formatter)
- flake8 (linter)
- mypy (type checker)
- pytest (testing framework)
- jupyter (notebook environment)

### Node.js Tools
- yarn, pnpm (package managers)
- typescript, ts-node
- eslint (linter)
- prettier (code formatter)
- nodemon (development server)
- pm2 (process manager)

### Database Clients
- PostgreSQL client
- MySQL client
- Redis tools

### Cloud & DevOps Tools
- AWS CLI
- Docker CLI (for Docker-in-Docker scenarios)

### System Utilities
- curl, wget, git, vim, nano, unzip, zip
- tree, htop, jq, net-tools, iputils-ping
- iotop, iftop (monitoring tools)

## Quick Start

### Using Pre-built Docker Image (Recommended)

The Docker image is automatically built and published to GitHub Container Registry with each release.

1. **Pull and run the latest image:**
   ```bash
   docker run -it --rm \
     -v $(pwd)/workspace:/home/developer/workspace \
     -p 3000:3000 -p 8000:8000 -p 8080:8080 \
     ghcr.io/YOUR_USERNAME/YOUR_REPO_NAME:latest
   ```

2. **Or use a specific version:**
   ```bash
   docker run -it --rm \
     -v $(pwd)/workspace:/home/developer/workspace \
     -p 3000:3000 -p 8000:8000 -p 8080:8080 \
     ghcr.io/YOUR_USERNAME/YOUR_REPO_NAME:v1.0.0
   ```

### Using Docker Compose with Pre-built Image

1. **Create a docker-compose.yml file:**
   ```yaml
   version: '3.8'
   services:
     devenv:
       image: ghcr.io/YOUR_USERNAME/YOUR_REPO_NAME:latest
       container_name: developer-environment
       volumes:
         - ./workspace:/home/developer/workspace
         - /var/run/docker.sock:/var/run/docker.sock
         - devenv-home:/home/developer
       ports:
         - "3000:3000"
         - "8000:8000"
         - "8080:8080"
       stdin_open: true
       tty: true
       command: tail -f /dev/null
   volumes:
     devenv-home:
   ```

2. **Start the container:**
   ```bash
   docker-compose up -d
   ```

3. **Access the development environment:**
   ```bash
   docker-compose exec devenv bash
   ```

### Building from Source

If you want to build the image yourself:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
   cd YOUR_REPO_NAME
   ```

2. **Build and start with Docker Compose:**
   ```bash
   docker-compose up -d
   ```

3. **Or build the image directly:**
   ```bash
   docker build -t devenv .
   docker run -it --rm \
     -v $(pwd)/workspace:/home/developer/workspace \
     -p 3000:3000 -p 8000:8000 -p 8080:8080 \
     devenv
   ```

## Usage Examples

### Python Development

```bash
# List available Python versions
pyenv versions

# Install a new Python version
pyenv install 3.10.12

# Set global Python version
pyenv global 3.12.1

# Create a virtual environment
python -m venv myproject
source myproject/bin/activate

# Or use pipenv
pipenv install requests
pipenv shell

# Or use poetry
poetry new myproject
cd myproject
poetry add requests
```

### Node.js Development

```bash
# List available Node.js versions
nvm list

# Install a specific Node.js version
nvm install 18.19.0

# Use a specific version
nvm use 18.19.0

# Install packages
npm install express
# or
yarn add express
# or
pnpm add express
```

### Go Development

```bash
# Go is installed in /usr/local/go/bin
go version

# Create a new Go module
go mod init myproject
```

### Rust Development

```bash
# Rust is installed via rustup
rustc --version
cargo --version

# Create a new Rust project
cargo new myproject
cd myproject
cargo build
```

## Port Mappings

The following ports are exposed and mapped:

- `3000`: React/Next.js development server
- `3001`: Alternative React port
- `4000`: GraphQL/Apollo server
- `5000`: Flask/Express server
- `8000`: Django/FastAPI server
- `8080`: Alternative web server
- `8888`: Jupyter Notebook
- `9000`: Additional service port

## Volume Mounts

- `./workspace` → `/home/developer/workspace`: Your local workspace
- `/var/run/docker.sock` → `/var/run/docker.sock`: Docker socket for Docker-in-Docker
- `devenv-home`: Persistent volume for user home directory (shell history, configs)

## User Configuration

The container runs as user `developer` with sudo privileges. The following are pre-configured:

- Shell aliases (ll, la, l, .., ..., colored grep)
- Git configuration (main as default branch, vim as editor)
- Environment variables for pyenv and nvm

## Customization

### Adding More Tools

To add additional tools, modify the Dockerfile and rebuild:

```dockerfile
# Add your custom tools here
RUN apt-get update && apt-get install -y your-tool
```

### Persistent Configuration

User configurations are persisted in the `devenv-home` volume. This includes:
- Shell history (.bash_history)
- Tool configurations (.gitconfig, .vimrc, etc.)
- Installed packages and environments

## Troubleshooting

### pyenv/nvm not found
If pyenv or nvm commands are not found, source the bashrc:
```bash
source ~/.bashrc
```

### Permission issues with Docker socket
Ensure your user is in the docker group on the host system:
```bash
sudo usermod -aG docker $USER
```

### Port conflicts
If ports are already in use, modify the port mappings in docker-compose.yml:
```yaml
ports:
  - "3001:3000"  # Map host port 3001 to container port 3000
```

## Development Workflow

1. Start the development environment:
   ```bash
   docker-compose up -d
   ```

2. Access the container:
   ```bash
   docker-compose exec devenv bash
   ```

3. Navigate to your workspace:
   ```bash
   cd ~/workspace
   ```

4. Start developing! All your tools are ready to use.

5. When done, stop the container:
   ```bash
   docker-compose down
   ```

Your work in the `workspace` directory will persist on your host machine, and your shell history and configurations will persist in the Docker volume.
