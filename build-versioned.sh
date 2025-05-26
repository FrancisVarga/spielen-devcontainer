#!/bin/bash

# Build script for versioned Docker images
# This script reads the version from package.json and builds a Docker image with that version

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if package.json exists
if [ ! -f "package.json" ]; then
    print_error "package.json not found in current directory"
    exit 1
fi

# Check if node is available
if ! command -v node &> /dev/null; then
    print_error "Node.js is required but not installed"
    exit 1
fi

# Get version from package.json
VERSION=$(node -p "require('./package.json').version" 2>/dev/null)

if [ -z "$VERSION" ]; then
    print_error "Could not read version from package.json"
    exit 1
fi

print_status "Building Docker image with version: $VERSION"

# Image name
IMAGE_NAME="developer-environment"

# Build the Docker image with version
print_status "Building image: ${IMAGE_NAME}:${VERSION}"
docker build \
    --build-arg VERSION="$VERSION" \
    -t "${IMAGE_NAME}:${VERSION}" \
    -t "${IMAGE_NAME}:latest" \
    .

if [ $? -eq 0 ]; then
    print_status "Successfully built Docker images:"
    echo "  - ${IMAGE_NAME}:${VERSION}"
    echo "  - ${IMAGE_NAME}:latest"
    
    print_status "Image details:"
    docker images "${IMAGE_NAME}" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
    
    print_status "To run the container:"
    echo "  docker run -d -p 2222:22 -p 3000:3000 ${IMAGE_NAME}:${VERSION}"
    
    print_status "To push to a registry (update registry URL as needed):"
    echo "  docker tag ${IMAGE_NAME}:${VERSION} your-registry/${IMAGE_NAME}:${VERSION}"
    echo "  docker push your-registry/${IMAGE_NAME}:${VERSION}"
else
    print_error "Docker build failed"
    exit 1
fi
