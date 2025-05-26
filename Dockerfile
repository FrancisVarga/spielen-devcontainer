# syntax=docker/dockerfile:1.7

# Build arguments for performance optimization
ARG BUILDKIT_INLINE_CACHE=1
ARG BUILDKIT_CACHE_MOUNT_NS=spielen-devcontainer
ARG VERSION=latest

# Stage 1: Base system with minimal dependencies
FROM alpine:3.19 AS base

# Set environment variables
ENV USER=developer
ENV HOME=/home/$USER
ENV TERM=xterm-256color
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

# Install essential system packages only
RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    apk add --no-cache \
    bash \
    curl \
    git \
    vim \
    openssh-server \
    sudo \
    shadow \
    ca-certificates \
    build-base \
    linux-headers \
    libffi-dev \
    openssl-dev \
    python3 \
    python3-dev \
    py3-pip \
    nodejs \
    npm \
    jq \
    tar \
    gzip

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    apk update && apk add --no-cache coreutils sed

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    apk add --no-cache make gcc zlib-dev bzip2 bzip2-dev readline-dev sqlite sqlite-dev openssl-dev xz xz-dev tk tk-dev

# Create developer user and configure SSH
RUN adduser -D -s /bin/bash $USER && \
    echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "$USER:password" | chpasswd && \
    mkdir -p /var/run/sshd && \
    ssh-keygen -A && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    echo "AllowUsers $USER" >> /etc/ssh/sshd_config

# Stage 2: Python environment (focused on essential tools only)
FROM base AS python-env

USER $USER
WORKDIR $HOME

# Create virtual environment and install essential Python packages
RUN --mount=type=cache,target=/home/$USER/.cache/pip,uid=1000,gid=1000 \
    python3 -m venv ~/.local/venv && \
    . ~/.local/venv/bin/activate && \
    pip install --upgrade pip && \
    pip install \
    black \
    flake8 \
    pytest \
    requests \
    virtualenv

# Stage 3: Node.js environment (minimal setup)
FROM python-env AS node-env

# Configure npm to install packages locally for the user
RUN npm config set prefix ~/.local

# Install pyenv dependencies and pyenv itself
RUN curl https://pyenv.run | bash

# Install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

# Set up environment variables for pyenv and nvm
ENV PYENV_ROOT="$HOME/.pyenv"
ENV NVM_DIR="$HOME/.nvm"
ENV PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$HOME/.local/bin:$PATH"

# Configure shell environment for both interactive and non-interactive shells
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo 'export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$HOME/.local/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(pyenv init --path)"' >> ~/.bashrc && \
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc

# Also add to .profile for non-interactive shells
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.profile && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.profile && \
    echo 'export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$HOME/.local/bin:$PATH"' >> ~/.profile && \
    echo 'eval "$(pyenv init --path)"' >> ~/.profile && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.profile

# Install essential Node.js packages only (removed heavy ones like pm2, pnpm)
RUN --mount=type=cache,target=/home/$USER/.npm,uid=1000,gid=1000 \
    npm install -g \
    typescript \
    eslint \
    prettier \
    nodemon

# Stage 4: Final optimized image
FROM node-env AS final

# Add minimal metadata labels with version from build arg
ARG VERSION
LABEL maintainer="Developer Environment" \
      version="${VERSION}" \
      description="Lightweight development container optimized for size" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.title="developer-environment" \
      org.opencontainers.image.description="Lightweight development container with Python, Node.js, and essential dev tools" \
      org.opencontainers.image.source="https://github.com/your-username/developer-environment"

USER $USER
WORKDIR $HOME

# Set up PATH for virtual environment and npm local packages
ENV PATH="$HOME/.local/venv/bin:$HOME/.local/bin:$PATH"

# Configure minimal shell environment
RUN echo 'export PATH="$HOME/.local/venv/bin:$HOME/.local/bin:$PATH"' >> ~/.bashrc && \
    echo 'alias ll="ls -alF"' >> ~/.bashrc && \
    echo 'alias la="ls -A"' >> ~/.bashrc && \
    echo 'alias l="ls -CF"' >> ~/.bashrc && \
    echo 'alias ..="cd .."' >> ~/.bashrc && \
    echo 'alias grep="grep --color=auto"' >> ~/.bashrc

# Set up git configuration and SSH (minimal setup)
RUN git config --global init.defaultBranch main && \
    git config --global pull.rebase false && \
    git config --global core.editor vim && \
    mkdir -p ~/.ssh ~/.cache ~/.local/bin ~/workspace && \
    chmod 700 ~/.ssh && \
    echo "# SSH keys will be configured at runtime" > ~/.ssh/authorized_keys && \
    chmod 600 ~/.ssh/authorized_keys

# Clean up to reduce image size
USER root
RUN apk del build-base linux-headers && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/* && \
    find /usr -name "*.pyc" -delete && \
    find /usr -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true

USER $USER
WORKDIR /home/$USER/workspace

# Expose essential ports only
EXPOSE 22 3000 8000

# Copy startup scripts and make them executable
USER root
COPY start.sh /start.sh
COPY setup-ssh-keys-runtime.sh /setup-ssh-keys-runtime.sh

# Fix line endings and make scripts executable
RUN sed -i 's/\r$//' /start.sh /setup-ssh-keys-runtime.sh && \
    chmod +x /start.sh /setup-ssh-keys-runtime.sh

# Add health check for SSH service
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD pgrep sshd > /dev/null || exit 1

# Default command
CMD ["/start.sh"]
