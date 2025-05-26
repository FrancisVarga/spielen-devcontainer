# Docker and GitHub Actions Caching Strategy

This document outlines the comprehensive caching strategy implemented for the spielen-devcontainer project to optimize build times and reduce resource usage.

## Overview

The caching strategy utilizes multiple layers of caching:
1. **Docker BuildKit Cache Mounts** - For package managers and build artifacts
2. **GitHub Actions Cache** - For Docker layers and build context
3. **Docker Registry Cache** - For layer reuse across builds

## Dockerfile Caching Enhancements

### Build Arguments
- `BUILDKIT_INLINE_CACHE=1` - Enables inline cache metadata
- `BUILDKIT_CACHE_MOUNT_NS=spielen-devcontainer` - Namespace for cache mounts

### Cache Mount Points
- `/var/cache/apk` - Alpine package manager cache (with `sharing=locked`)
- `/home/$USER/.cache/pip` - Python pip cache (user-specific)
- `/home/$USER/.npm` - Node.js npm cache (user-specific)

### Multi-stage Build Optimization
- **Base Stage**: System packages with APK cache mounts
- **Python Stage**: Virtual environment with pip cache
- **Node Stage**: Global packages with npm cache
- **Final Stage**: Optimized runtime image

## GitHub Actions Caching

### Docker Build Workflow (`docker-build.yml`)
- **GitHub Actions Cache**: `/tmp/.buildx-cache` for Docker layers
- **Cache Keys**: 
  - Primary: `${{ runner.os }}-buildx-${{ github.sha }}`
  - Fallback: `${{ runner.os }}-buildx-`
- **Cache Types**:
  - `type=gha` - GitHub Actions cache backend
  - `type=local` - Local filesystem cache

### Release Workflow (`release-please.yml`)
- **Conditional Execution**: Only runs when a release is created
- **Multi-platform Builds**: `linux/amd64,linux/arm64`
- **Registry Push**: GitHub Container Registry (`ghcr.io`)
- **Cache Inheritance**: Reuses cache from build workflow
- **Cache Keys**:
  - Primary: `${{ runner.os }}-buildx-release-${{ github.sha }}`
  - Fallback: `${{ runner.os }}-buildx-release-`, `${{ runner.os }}-buildx-`

## Cache Benefits

### Build Time Reduction
- **Package Installation**: APK, pip, and npm caches eliminate redundant downloads
- **Layer Reuse**: Docker layer caching reduces rebuild times
- **Cross-workflow Sharing**: Cache sharing between build and release workflows

### Resource Optimization
- **Bandwidth**: Reduced network usage for package downloads
- **Storage**: Efficient layer sharing and cache management
- **Compute**: Faster builds reduce CI/CD execution time

## Cache Management

### Cache Invalidation
- **Dockerfile Changes**: Automatically invalidates relevant cache layers
- **Package Updates**: Cache mounts handle package manager updates efficiently
- **Git SHA**: Ensures cache freshness per commit

### Cache Cleanup
- **Automatic Rotation**: GitHub Actions cache has built-in retention policies
- **Manual Cleanup**: Cache directories are cleaned between builds
- **Size Limits**: Cache size is managed to prevent storage bloat

## Best Practices

### Docker
1. Use cache mounts for package managers
2. Leverage multi-stage builds for optimization
3. Order Dockerfile instructions by change frequency
4. Use specific cache namespaces to avoid conflicts

### GitHub Actions
1. Use multiple cache backends for redundancy
2. Implement proper cache key strategies
3. Share cache between related workflows
4. Monitor cache hit rates and effectiveness

## Monitoring and Troubleshooting

### Cache Hit Rates
- Monitor build logs for cache hit/miss information
- Track build time improvements over time
- Identify cache invalidation patterns

### Common Issues
- **Cache Miss**: Check cache key patterns and Dockerfile changes
- **Build Failures**: Verify cache mount permissions and paths
- **Storage Limits**: Monitor cache size and implement cleanup strategies

## Future Enhancements

1. **Registry Cache**: Implement Docker registry cache for public images
2. **Dependency Caching**: Add language-specific dependency caches
3. **Parallel Builds**: Optimize cache sharing for parallel build jobs
4. **Cache Analytics**: Implement detailed cache performance monitoring
