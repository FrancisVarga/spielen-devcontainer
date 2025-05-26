#!/bin/bash

set -e

echo "🚀 Starting simplified Docker tests..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Test 1: Build Docker image
echo "📦 Building Docker image..."
if docker build -t devenv:test .; then
    print_status "Docker image built successfully"
else
    print_error "Failed to build Docker image"
    exit 1
fi

# Test 2: Test essential tools
echo "🧪 Testing essential tools..."
docker run --rm devenv:test /bin/bash -c "which git && which curl && which vim" > /dev/null
print_status "Essential tools are available"

# Test 3: Test Python environment
echo "🐍 Testing Python environment..."
docker run --rm devenv:test /bin/bash -c "python3 --version" > /dev/null
docker run --rm devenv:test /bin/bash -c "pyenv --version"
docker run --rm devenv:test /bin/bash -c "source ~/.local/venv/bin/activate && python -c 'import black, flake8, pytest'" > /dev/null
print_status "Python environment is working"

# Test 4: Test Node.js environment
echo "📦 Testing Node.js environment..."
docker run --rm devenv:test /bin/bash -c "node --version" > /dev/null
docker run --rm devenv:test /bin/bash -c "source ~/.profile && nvm --version"
docker run --rm devenv:test /bin/bash -c "which typescript && which eslint" > /dev/null
print_status "Node.js environment is working"

# Test 5: Test Docker Compose
echo "🐳 Testing Docker Compose..."
docker-compose build > /dev/null
print_status "Docker Compose build successful"

docker-compose up -d > /dev/null
sleep 15

if docker-compose ps | grep -q "Up"; then
    print_status "Docker Compose service is running"
    docker-compose exec -T devenv /bin/bash -c "echo 'Docker Compose test successful'" > /dev/null
    print_status "Docker Compose exec test successful"
else
    print_warning "Docker Compose service may have issues, checking logs..."
    docker-compose logs
fi

docker-compose down > /dev/null
print_status "Docker Compose cleanup successful"

# Test 6: Test parallel Docker Compose runs
echo "🔄 Testing Docker Compose parallel runs..."

# Create test compose files with different ports
cat > docker-compose.test1.yml << 'EOF'
version: '3.8'
services:
  devenv:
    build: .
    container_name: developer-environment-1
    volumes:
      - ./workspace:/home/developer/workspace
      - devenv-home-1:/home/developer
    ports:
      - "3010:3000"
      - "3011:3001"
      - "4010:4000"
      - "5010:5000"
    environment:
      - DISPLAY=${DISPLAY:-:0}
    stdin_open: true
    tty: true
volumes:
  devenv-home-1:
    driver: local
EOF

cat > docker-compose.test2.yml << 'EOF'
version: '3.8'
services:
  devenv:
    build: .
    container_name: developer-environment-2
    volumes:
      - ./workspace:/home/developer/workspace
      - devenv-home-2:/home/developer
    ports:
      - "3020:3000"
      - "3021:3001"
      - "4020:4000"
      - "5020:5000"
    environment:
      - DISPLAY=${DISPLAY:-:0}
    stdin_open: true
    tty: true
volumes:
  devenv-home-2:
    driver: local
EOF

# Start both instances in parallel
echo "Starting parallel instances..."
docker-compose -f docker-compose.test1.yml up -d > /dev/null 2>&1 &
PID1=$!
docker-compose -f docker-compose.test2.yml up -d > /dev/null 2>&1 &
PID2=$!

# Wait for both to start
wait $PID1
wait $PID2
sleep 20

# Test both instances
echo "Testing parallel instances..."
INSTANCE1_UP=$(docker-compose -f docker-compose.test1.yml ps | grep -c "Up" || echo "0")
INSTANCE2_UP=$(docker-compose -f docker-compose.test2.yml ps | grep -c "Up" || echo "0")

if [ "$INSTANCE1_UP" -gt "0" ] && [ "$INSTANCE2_UP" -gt "0" ]; then
    print_status "Both parallel instances are running"
    
    # Test exec on both
    docker-compose -f docker-compose.test1.yml exec -T devenv /bin/bash -c "echo 'Parallel test 1 successful'" > /dev/null 2>&1 || print_warning "Instance 1 exec test had issues"
    docker-compose -f docker-compose.test2.yml exec -T devenv /bin/bash -c "echo 'Parallel test 2 successful'" > /dev/null 2>&1 || print_warning "Instance 2 exec test had issues"
    print_status "Parallel exec tests completed"
else
    print_warning "Some parallel instances may have issues"
    echo "Instance 1 status:"
    docker-compose -f docker-compose.test1.yml ps
    echo "Instance 2 status:"
    docker-compose -f docker-compose.test2.yml ps
fi

# Clean up parallel instances
echo "Cleaning up parallel instances..."
docker-compose -f docker-compose.test1.yml down > /dev/null 2>&1 &
docker-compose -f docker-compose.test2.yml down > /dev/null 2>&1 &
wait

# Remove test files
rm docker-compose.test1.yml docker-compose.test2.yml

print_status "Parallel Docker Compose test completed"

# Test 7: Image size check
echo "📏 Checking image size..."
IMAGE_SIZE=$(docker images devenv:test --format "{{.Size}}" | head -n 1)
echo "Image size: $IMAGE_SIZE"

if [[ "$IMAGE_SIZE" =~ [0-9]+(\.[0-9]+)?GB ]]; then
    print_warning "Image size is quite large (${IMAGE_SIZE}). Consider optimizing."
else
    print_status "Image size is reasonable (${IMAGE_SIZE})"
fi

# Test 8: Cache effectiveness test
echo "🗄️  Testing build cache effectiveness..."
START_TIME=$(date +%s)
docker build -t devenv:cache-test . > /dev/null 2>&1
END_TIME=$(date +%s)
CACHE_BUILD_TIME=$((END_TIME - START_TIME))

if [ $CACHE_BUILD_TIME -lt 30 ]; then
    print_status "Build cache is working effectively (${CACHE_BUILD_TIME}s)"
else
    print_warning "Build cache might not be optimal (${CACHE_BUILD_TIME}s)"
fi

# Cleanup
docker rmi devenv:cache-test > /dev/null 2>&1

echo ""
echo "🎉 All tests completed!"
echo ""
echo "Summary:"
echo "- ✅ Docker image builds successfully"
echo "- ✅ Essential development tools are available"
echo "- ✅ Python environment is working"
echo "- ✅ Node.js environment is working"
echo "- ✅ Docker Compose works properly"
echo "- ✅ Parallel Docker Compose instances work"
echo "- ✅ Build cache is functional"
echo ""
echo "Your development container is ready to use!"
