#!/bin/bash

# Optimized Docker build script with BuildKit parallel builds and caching
# This script demonstrates how to build the container with maximum performance

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="${IMAGE_NAME:-dev-environment}"
TAG="${TAG:-latest}"
REGISTRY="${REGISTRY:-ghcr.io/your_username/your_repo_name}"
FULL_IMAGE_NAME="${REGISTRY}:${TAG}"

# BuildKit configuration for maximum performance
export DOCKER_BUILDKIT=1
export BUILDKIT_PROGRESS=plain

echo -e "${BLUE}🚀 Starting optimized Docker build with BuildKit...${NC}"
echo -e "${YELLOW}Image: ${FULL_IMAGE_NAME}${NC}"

# Check if BuildKit is available
if ! docker buildx version >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker BuildKit (buildx) is not available. Please install it first.${NC}"
    exit 1
fi

# Create a new builder instance if it doesn't exist
BUILDER_NAME="dev-env-builder"
if ! docker buildx inspect "$BUILDER_NAME" >/dev/null 2>&1; then
    echo -e "${YELLOW}📦 Creating new BuildKit builder instance...${NC}"
    docker buildx create --name "$BUILDER_NAME" --driver docker-container --bootstrap
fi

# Use the builder
docker buildx use "$BUILDER_NAME"

echo -e "${BLUE}🔧 Builder configuration:${NC}"
docker buildx inspect --bootstrap

# Build with maximum parallelization and caching
echo -e "${GREEN}🏗️  Building with parallel stages and aggressive caching...${NC}"

# Build command with all optimizations
# Only use cache-from if cache directory exists
CACHE_ARGS=""
if [ -d "/tmp/.buildx-cache" ] && [ -f "/tmp/.buildx-cache/index.json" ]; then
    CACHE_ARGS="--cache-from type=local,src=/tmp/.buildx-cache"
fi

docker buildx build \
    --builder "$BUILDER_NAME" \
    --tag "$FULL_IMAGE_NAME" \
    --tag "$IMAGE_NAME:$TAG" \
    $CACHE_ARGS \
    --cache-to type=local,dest=/tmp/.buildx-cache-new,mode=max \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --progress=plain \
    --load \
    .

# Move cache to avoid growing cache
if [ -d "/tmp/.buildx-cache-new" ]; then
    rm -rf /tmp/.buildx-cache
    mv /tmp/.buildx-cache-new /tmp/.buildx-cache
fi

echo -e "${GREEN}✅ Build completed successfully!${NC}"

# Show image information
echo -e "${BLUE}📊 Image information:${NC}"
docker images "$IMAGE_NAME:$TAG" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"

# Optional: Test the container
if [ "${TEST_CONTAINER:-false}" = "true" ]; then
    echo -e "${YELLOW}🧪 Testing container...${NC}"
    
    # Start container in background
    CONTAINER_ID=$(docker run -d --rm -p 2222:22 "$IMAGE_NAME:$TAG")
    
    # Wait a moment for SSH to start
    sleep 5
    
    # Test SSH connection
    if docker exec "$CONTAINER_ID" service ssh status >/dev/null 2>&1; then
        echo -e "${GREEN}✅ SSH service is running${NC}"
    else
        echo -e "${RED}❌ SSH service failed to start${NC}"
    fi
    
    # Test development tools
    echo -e "${BLUE}🔍 Checking development tools...${NC}"
    docker exec "$CONTAINER_ID" su - developer -c "python --version && node --version && go version && rustc --version"
    
    # Stop test container
    docker stop "$CONTAINER_ID"
    echo -e "${GREEN}✅ Container test completed${NC}"
fi

# Show build cache information
echo -e "${BLUE}💾 Build cache information:${NC}"
if [ -d "/tmp/.buildx-cache" ]; then
    du -sh /tmp/.buildx-cache
else
    echo "No build cache found"
fi

echo -e "${GREEN}🎉 Build process completed!${NC}"
echo -e "${YELLOW}To run the container:${NC}"
echo -e "  docker run -d -p 2222:22 -p 3000:3000 -p 8080:8080 --name dev-env $IMAGE_NAME:$TAG"
echo -e "${YELLOW}To connect via SSH:${NC}"
echo -e "  ssh -p 2222 developer@localhost"
