# Release and Deployment Guide

This document explains how the automated release and Docker image deployment process works using release-please and GitHub Actions.

## Overview

This project uses [release-please](https://github.com/googleapis/release-please) to automate the release process and GitHub Actions to build and deploy Docker images to GitHub Container Registry (GHCR).

## How It Works

### 1. Conventional Commits

The release process is triggered by conventional commits. Use the following commit message format:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### Commit Types

- `feat:` - A new feature (triggers minor version bump)
- `fix:` - A bug fix (triggers patch version bump)
- `feat!:` or `fix!:` - Breaking change (triggers major version bump)
- `chore:` - Maintenance tasks
- `docs:` - Documentation changes
- `style:` - Code style changes
- `refactor:` - Code refactoring
- `perf:` - Performance improvements
- `test:` - Adding or updating tests
- `build:` - Build system changes
- `ci:` - CI/CD changes

#### Examples

```bash
# Feature addition (minor version bump)
git commit -m "feat: add support for Python 3.13"

# Bug fix (patch version bump)
git commit -m "fix: resolve Docker build issue with ARM64"

# Breaking change (major version bump)
git commit -m "feat!: change default Python version to 3.12"

# Documentation update
git commit -m "docs: update installation instructions"
```

### 2. Release Process

1. **Push commits to main branch**: When you push commits with conventional commit messages to the main branch, release-please analyzes the commits.

2. **Release PR creation**: If there are releasable changes, release-please creates a "Release PR" that:
   - Updates the version in `.release-please-manifest.json`
   - Updates the `CHANGELOG.md` with new changes
   - Creates a release commit

3. **Merge Release PR**: When you merge the Release PR, release-please:
   - Creates a new GitHub release
   - Tags the release with the new version
   - Triggers the Docker image build and deployment

4. **Docker Image Build**: The GitHub Actions workflow automatically:
   - Builds the Docker image for multiple architectures (amd64, arm64)
   - Pushes the image to GitHub Container Registry with version tags
   - Updates the `latest` tag

## Using the Released Docker Images

### Available Tags

After each release, the following Docker image tags are available:

- `ghcr.io/YOUR_USERNAME/YOUR_REPO_NAME:latest` - Latest release
- `ghcr.io/YOUR_USERNAME/YOUR_REPO_NAME:v1.0.0` - Specific version
- `ghcr.io/YOUR_USERNAME/YOUR_REPO_NAME:1.0` - Major.minor version
- `ghcr.io/YOUR_USERNAME/YOUR_REPO_NAME:1` - Major version

### Pull and Run

```bash
# Pull the latest version
docker pull ghcr.io/YOUR_USERNAME/YOUR_REPO_NAME:latest

# Run the container
docker run -it --rm \
  -v $(pwd)/workspace:/home/developer/workspace \
  -p 3000:3000 -p 8000:8000 -p 8080:8080 \
  ghcr.io/YOUR_USERNAME/YOUR_REPO_NAME:latest
```

### Use in Docker Compose

```yaml
version: '3.8'
services:
  devenv:
    image: ghcr.io/YOUR_USERNAME/YOUR_REPO_NAME:latest
    # ... rest of your configuration
```

### Use in DevContainers

Create a `.devcontainer/devcontainer.json` file:

```json
{
  "name": "Developer Environment",
  "image": "ghcr.io/YOUR_USERNAME/YOUR_REPO_NAME:latest",
  "features": {},
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-vscode.vscode-typescript-next"
      ]
    }
  },
  "forwardPorts": [3000, 8000, 8080],
  "postCreateCommand": "echo 'Welcome to your development environment!'",
  "remoteUser": "developer"
}
```

## Manual Release Process

If you need to create a release manually:

1. **Create a release commit**:
   ```bash
   git commit -m "chore: release v1.0.0"
   ```

2. **Push to main**:
   ```bash
   git push origin main
   ```

3. **Create a GitHub release**: Go to the GitHub repository and create a new release with the appropriate tag.

## Configuration Files

### release-please-config.json

This file configures release-please behavior:

```json
{
  "packages": {
    ".": {
      "release-type": "simple",
      "package-name": "developer-environment",
      "changelog-sections": [
        {"type": "feat", "section": "Features"},
        {"type": "fix", "section": "Bug Fixes"},
        // ... other sections
      ]
    }
  }
}
```

### .release-please-manifest.json

This file tracks the current version:

```json
{
  ".": "1.0.0"
}
```

## GitHub Actions Workflows

### release-please.yml

- Runs on every push to main
- Creates release PRs and GitHub releases
- Builds and pushes Docker images when releases are created

### docker-build.yml

- Runs on pull requests and pushes that modify Docker-related files
- Tests the Docker image build process
- Runs security scans with Trivy

## Troubleshooting

### Release PR not created

- Ensure your commits follow conventional commit format
- Check that you have releasable changes (feat, fix, etc.)
- Verify the release-please configuration is correct

### Docker image build fails

- Check the GitHub Actions logs for build errors
- Ensure all required files are present and not ignored by `.dockerignore`
- Verify the Dockerfile syntax is correct

### Permission issues

- Ensure the repository has the correct permissions for GitHub Actions
- Check that the `GITHUB_TOKEN` has the necessary scopes

### Image not available in GHCR

- Verify the image was successfully pushed (check Actions logs)
- Ensure the repository visibility settings allow package access
- Check that you're using the correct image name and tag

## Best Practices

1. **Use conventional commits**: Always use the conventional commit format for automatic version bumping.

2. **Test before releasing**: The CI pipeline tests the Docker image build, but test locally when possible.

3. **Review release PRs**: Always review the generated release PR before merging.

4. **Pin versions in production**: Use specific version tags rather than `latest` in production environments.

5. **Monitor releases**: Keep an eye on the GitHub Actions workflows to ensure successful builds and deployments.

## Security

- Docker images are scanned with Trivy for security vulnerabilities
- Images are built with multi-stage builds to minimize attack surface
- Regular base image updates are recommended
- Use specific version tags for better security and reproducibility
