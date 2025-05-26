# Package Versioning Guide

This project uses automated versioning that synchronizes between package.json and Docker image releases.

## Overview

- **Package Version**: Managed in `package.json` (currently `0.6.0`)
- **Release Management**: Automated via `release-please`
- **Docker Images**: Tagged with semantic versions matching package.json
- **GitHub Releases**: Created automatically when version changes

## Versioning Workflow

### 1. Development Process

1. Make changes to the codebase
2. Commit with conventional commit messages:
   ```bash
   git commit -m "feat: add new development tool"
   git commit -m "fix: resolve container startup issue"
   git commit -m "chore: update dependencies"
   ```

### 2. Automated Release Process

1. **Release Please** monitors commits on `main` branch
2. Creates a release PR when conventional commits are detected
3. Updates `package.json` version and `CHANGELOG.md`
4. When PR is merged, creates a GitHub release
5. **Docker Build** workflow triggers on release
6. Builds and publishes versioned Docker images

### 3. Docker Image Versioning

Images are tagged with multiple versions:
- `ghcr.io/your-repo/developer-environment:0.6.0` (exact version)
- `ghcr.io/your-repo/developer-environment:0.6` (minor version)
- `ghcr.io/your-repo/developer-environment:0` (major version)
- `ghcr.io/your-repo/developer-environment:latest` (latest release)

## Local Development

### Building Versioned Images Locally

```bash
# Using npm script (Windows/PowerShell)
npm run build:versioned

# Using bash script (Linux/macOS/WSL)
npm run build:versioned:bash

# Manual build with version
docker build --build-arg VERSION=0.6.0 -t developer-environment:0.6.0 .
```

### Available npm Scripts

```bash
# Build latest version
npm run build

# Build with current package.json version
npm run build:versioned

# Show current version
npm run version:show

# Run container with current version
npm run docker:run

# View logs of running container
npm run docker:logs

# Start with docker-compose
npm run start

# Stop docker-compose
npm run stop

# Clean up Docker resources
npm run clean

# Run tests
npm run test
```

## Conventional Commits

Use these commit types to trigger appropriate version bumps:

- `feat:` - New features (minor version bump)
- `fix:` - Bug fixes (patch version bump)
- `BREAKING CHANGE:` - Breaking changes (major version bump)
- `chore:` - Maintenance tasks (no version bump)
- `docs:` - Documentation updates (no version bump)
- `style:` - Code style changes (no version bump)
- `refactor:` - Code refactoring (no version bump)
- `test:` - Test updates (no version bump)

## Configuration Files

### release-please-config.json
```json
{
  "packages": {
    ".": {
      "release-type": "node",
      "package-name": "developer-environment",
      "extra-files": [
        {
          "type": "json",
          "path": "package.json",
          "jsonpath": "$.version"
        }
      ]
    }
  }
}
```

### .release-please-manifest.json
```json
{
  ".": "0.6.0"
}
```

## GitHub Actions Workflows

### 1. Release Please (`.github/workflows/release-please.yml`)
- Monitors conventional commits
- Creates release PRs
- Generates releases when PRs are merged

### 2. Docker Build (`.github/workflows/docker-build.yml`)
- Tests Docker builds on PRs and pushes
- Publishes versioned images on releases
- Supports multi-platform builds (amd64, arm64)

## Version Synchronization

The system ensures version consistency across:

1. **package.json** - Source of truth for version
2. **Docker image labels** - Built with VERSION build arg
3. **GitHub releases** - Created by release-please
4. **Container registry tags** - Multiple semantic version tags

## Troubleshooting

### Version Mismatch
If versions get out of sync:

1. Check `.release-please-manifest.json`
2. Verify `package.json` version
3. Ensure Docker builds use correct VERSION arg
4. Review GitHub Actions logs

### Manual Version Update
To manually update version:

```bash
# Update package.json version
npm version patch|minor|major

# Update release-please manifest
# Edit .release-please-manifest.json manually

# Commit changes
git add .
git commit -m "chore: bump version to x.y.z"
```

### Docker Image Verification
Check image version labels:

```bash
docker inspect developer-environment:0.6.0 | grep -A 10 Labels
```

## Best Practices

1. **Always use conventional commits** for automatic versioning
2. **Test locally** before pushing to main
3. **Review release PRs** before merging
4. **Use semantic versioning** principles
5. **Document breaking changes** in commit messages
6. **Keep CHANGELOG.md** updated (automated by release-please)

## Integration with CI/CD

The versioning system integrates with:

- **GitHub Actions** for automated builds
- **GitHub Container Registry** for image storage
- **Release Please** for version management
- **Docker Buildx** for multi-platform builds
- **Conventional Commits** for semantic versioning
