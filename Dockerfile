# syntax=docker/dockerfile:1.7

# Build arguments for performance optimization
ARG BUILDKIT_INLINE_CACHE=1

# Stage 1: Base system setup with dependencies
FROM ubuntu:22.04 AS base

# Set environment variables for performance and non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash
ENV USER=developer
ENV HOME=/home/$USER
ENV TERM=xterm-256color
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
# Performance optimizations
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV NPM_CONFIG_CACHE=/tmp/.npm
ENV YARN_CACHE_FOLDER=/tmp/.yarn

# Install system dependencies and developer tools in parallel-friendly layers
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache && \
    apt-get update && apt-get install -y \
    # Basic utilities (most frequently used first for better caching)
    curl \
    wget \
    git \
    vim \
    nano \
    unzip \
    zip \
    tree \
    htop \
    jq \
    # Build tools
    build-essential \
    make \
    cmake \
    gcc \
    g++ \
    # Network and system tools
    net-tools \
    iputils-ping \
    telnet \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    # Text processing and archives
    sed \
    grep \
    tar \
    gzip

# Install Python build dependencies in separate layer for better caching
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get install -y \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev

# Install SSH and process management tools
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get install -y \
    openssh-server \
    supervisor

# Create developer user and configure SSH (lightweight operations)
RUN useradd -m -s /bin/bash $USER && \
    usermod -aG sudo $USER && \
    echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "$USER:password" | chpasswd && \
    mkdir -p /var/run/sshd && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    echo "AllowUsers $USER" >> /etc/ssh/sshd_config

# Stage 2: Python environment (can run in parallel with other stages)
FROM base AS python-env

USER $USER
WORKDIR $HOME

# Install pyenv with optimized caching
RUN --mount=type=cache,target=/home/$USER/.cache/git,uid=1000,gid=1000 \
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv

# Set up pyenv environment
ENV PYENV_ROOT="$HOME/.pyenv"
ENV PATH="$PYENV_ROOT/bin:$PATH"

# Install Python versions with cache mount for builds
RUN --mount=type=cache,target=/home/$USER/.cache/pyenv,uid=1000,gid=1000 \
    --mount=type=cache,target=/tmp/python-build,uid=1000,gid=1000 \
    eval "$(pyenv init -)" && \
    pyenv install 3.12.1 && \
    pyenv global 3.12.1

# Install Python development tools with cache
RUN --mount=type=cache,target=/home/$USER/.cache/pip,uid=1000,gid=1000 \
    eval "$(pyenv init -)" && \
    pip install --upgrade pip && \
    pip install pipenv poetry virtualenv black flake8 mypy pytest jupyter

# Stage 3: Node.js environment (parallel with Python)
FROM base AS node-env

USER $USER
WORKDIR $HOME

# Install nvm with cache mount
RUN --mount=type=cache,target=/home/$USER/.cache/nvm,uid=1000,gid=1000 \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

ENV NVM_DIR="$HOME/.nvm"

# Install Node.js versions with cache
RUN --mount=type=cache,target=/home/$USER/.cache/nvm,uid=1000,gid=1000 \
    --mount=type=cache,target=/home/$USER/.npm,uid=1000,gid=1000 \
    . "$NVM_DIR/nvm.sh" && \
    nvm install --lts && \
    nvm install node && \
    nvm use --lts && \
    nvm alias default lts/*

# Install Node.js development tools with cache
RUN --mount=type=cache,target=/home/$USER/.npm,uid=1000,gid=1000 \
    . "$NVM_DIR/nvm.sh" && \
    nvm use --lts && \
    npm install -g yarn pnpm typescript ts-node eslint prettier nodemon pm2

# Stage 4: Rust environment (parallel with Python and Node)
FROM base AS rust-env

USER $USER
WORKDIR $HOME

# Create cargo directory with proper permissions first
RUN mkdir -p ~/.cargo/bin ~/.cargo/registry

# Install Rust with cache mount and better error handling
RUN --mount=type=cache,target=/home/$USER/.cache/rustup,uid=1000,gid=1000 \
    --mount=type=cache,target=/home/$USER/.cargo/registry,uid=1000,gid=1000 \
    curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs -o rustup-init.sh && \
    chmod +x rustup-init.sh && \
    ./rustup-init.sh -y --no-modify-path && \
    rm rustup-init.sh

# Stage 5: Go environment (parallel with others)
FROM base AS go-env

USER root

# Install Go with cache mount for downloads
RUN --mount=type=cache,target=/tmp/go-downloads \
    cd /tmp/go-downloads && \
    if [ ! -f go1.21.5.linux-amd64.tar.gz ]; then \
        wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz; \
    fi && \
    tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz

# Stage 6: Additional tools installation (parallel)
FROM base AS additional-tools

USER root

# Install Docker CLI with cache
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli

# Install database clients and cloud tools
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get install -y \
    postgresql-client \
    mysql-client \
    redis-tools \
    awscli \
    iotop \
    iftop \
    emacs-nox

# Install GitHub CLI
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh

# Stage 7: Final assembly (combines all parallel stages)
FROM additional-tools AS final

# Add performance and metadata labels
LABEL maintainer="Developer Environment" \
      version="2.0" \
      description="High-performance development container with BuildKit parallel builds and caching optimizations" \
      org.opencontainers.image.title="Development Environment" \
      org.opencontainers.image.description="Optimized development container with BuildKit parallel caching" \
      org.opencontainers.image.vendor="Development Team"

USER $USER
WORKDIR $HOME

# Copy environment configurations from parallel stages
COPY --from=python-env --chown=$USER:$USER /home/$USER/.pyenv /home/$USER/.pyenv
COPY --from=node-env --chown=$USER:$USER /home/$USER/.nvm /home/$USER/.nvm
COPY --from=rust-env --chown=$USER:$USER /home/$USER/.cargo /home/$USER/.cargo
COPY --from=go-env --chown=$USER:$USER /usr/local/go /usr/local/go

# Set up all environment variables
ENV PYENV_ROOT="$HOME/.pyenv"
ENV PATH="$PYENV_ROOT/bin:$PATH"
ENV NVM_DIR="$HOME/.nvm"
ENV PATH="$PATH:/usr/local/go/bin:$HOME/.cargo/bin"

# Configure shell environment in a single layer
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc && \
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc && \
    echo 'export PATH="$PATH:/usr/local/go/bin:$HOME/.cargo/bin"' >> ~/.bashrc && \
    # Shell aliases and configurations
    echo 'alias ll="ls -alF"' >> ~/.bashrc && \
    echo 'alias la="ls -A"' >> ~/.bashrc && \
    echo 'alias l="ls -CF"' >> ~/.bashrc && \
    echo 'alias ..="cd .."' >> ~/.bashrc && \
    echo 'alias ...="cd ../.."' >> ~/.bashrc && \
    echo 'alias grep="grep --color=auto"' >> ~/.bashrc && \
    echo 'alias fgrep="fgrep --color=auto"' >> ~/.bashrc && \
    echo 'alias egrep="egrep --color=auto"' >> ~/.bashrc && \
    # Performance optimizations
    echo 'export HISTCONTROL=ignoreboth:erasedups' >> ~/.bashrc && \
    echo 'export HISTSIZE=10000' >> ~/.bashrc && \
    echo 'export HISTFILESIZE=20000' >> ~/.bashrc

# Set up git configuration and SSH
RUN git config --global init.defaultBranch main && \
    git config --global pull.rebase false && \
    git config --global core.editor vim && \
    # SSH setup
    mkdir -p ~/.ssh ~/.cache ~/.local/bin ~/workspace && \
    chmod 700 ~/.ssh && \
    curl -s https://api.github.com/users/FrancisVarga/keys | jq -r '.[].key' > ~/.ssh/authorized_keys && \
    chmod 600 ~/.ssh/authorized_keys

# Set working directory
WORKDIR /home/$USER/workspace

# Expose common development ports and SSH
EXPOSE 22 3000 3001 4000 5000 8000 8080 8888 9000

# Copy startup script and make it executable
USER root
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Add health check for SSH service
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD service ssh status || exit 1

# Default command - start SSH and switch to developer user
CMD ["/start.sh"]
