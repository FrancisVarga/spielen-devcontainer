# syntax=docker/dockerfile:1.7

# Build arguments for performance optimization
ARG BUILDKIT_INLINE_CACHE=1

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
RUN apk add --no-cache \
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

# Install essential Node.js packages only (removed heavy ones like pm2, pnpm)
RUN --mount=type=cache,target=/home/$USER/.npm,uid=1000,gid=1000 \
    npm install -g \
    typescript \
    eslint \
    prettier \
    nodemon

# Stage 4: Final optimized image
FROM node-env AS final

# Add minimal metadata labels
LABEL maintainer="Developer Environment" \
      version="3.0-optimized" \
      description="Lightweight development container optimized for size"

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
    curl -s https://api.github.com/users/FrancisVarga/keys | jq -r '.[].key' > ~/.ssh/authorized_keys 2>/dev/null || echo "# Add your SSH keys here" > ~/.ssh/authorized_keys && \
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

# Copy startup script and make it executable
USER root
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Add health check for SSH service
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD pgrep sshd > /dev/null || exit 1

# Default command
CMD ["/start.sh"]
