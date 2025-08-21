#!/bin/bash
# Docker deployment script
# Usage: ./deploy.sh [dev|prod|build|push]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="mern-auth-app"
REGISTRY="your-registry.com"
VERSION=${VERSION:-latest}

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Load environment variables (fixed to handle comments)
load_env() {
    if [ -f .env ]; then
        echo_info "Loading environment variables from .env"
        # Export only non-comment, non-empty lines
        export $(grep -v '^#' .env | grep -v '^$' | xargs)
    else
        echo_warn "No .env file found. Using default values."
    fi
}

# Development deployment
deploy_dev() {
    echo_info "Starting development environment..."
    
    # Create .env file if it doesn't exist
    if [ ! -f .env ]; then
        echo_info "Creating development .env file..."
        cat > .env << EOF
# Development Environment Variables
NODE_ENV=development
MONGO_ROOT_USERNAME=admin
MONGO_ROOT_PASSWORD=admin123
MONGO_DB=mern_auth_db
JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
BACKEND_PORT=5000
FRONTEND_PORT=3000
REDIS_PORT=6379
EOF
        echo_info "Generated secure JWT_SECRET for development"
    fi
    
    load_env
    
    # Start development services
    docker-compose down
    docker-compose up --build -d
    
    echo_info "Development environment started!"
    echo_info "Frontend: http://localhost:${FRONTEND_PORT:-3000}"
    echo_info "Backend: http://localhost:${BACKEND_PORT:-5000}"
    echo_info "MongoDB: mongodb://localhost:${MONGO_PORT:-27017}"
}

# Production deployment
deploy_prod() {
    echo_info "Starting production environment..."
    
    # Check for production environment file
    if [ ! -f .env.prod ]; then
        echo_error "Production environment file (.env.prod) not found!"
        echo_info "Create .env.prod with your production settings:"
        echo_info "  MONGODB_URI=mongodb+srv://..."
        echo_info "  JWT_SECRET=your-production-jwt-secret"
        echo_info "  CORS_ORIGIN=https://yourdomain.com"
        exit 1
    fi
    
    # Load production environment (filter comments here too)
    export $(grep -v '^#' .env.prod | grep -v '^$' | xargs)
    
    # Build and start production services
    docker-compose -f docker-compose.prod.yml down
    docker-compose -f docker-compose.prod.yml up --build -d
    
    echo_info "Production environment started!"
    echo_info "Access your application at: http://localhost"
}

# Build images
build_images() {
    echo_info "Building Docker images..."
    
    # Build backend
    echo_info "Building backend image..."
    docker build -t ${REGISTRY}/${PROJECT_NAME}-backend:${VERSION} ./backend
    
    # Build frontend
    echo_info "Building frontend image..."
    docker build -t ${REGISTRY}/${PROJECT_NAME}-frontend:${VERSION} ./frontend
    
    echo_info "Images built successfully!"
}

# Push images to registry
push_images() {
    echo_info "Pushing images to registry..."
    
    # Login to registry (customize as needed)
    # docker login ${REGISTRY}
    
    # Push backend
    echo_info "Pushing backend image..."
    docker push ${REGISTRY}/${PROJECT_NAME}-backend:${VERSION}
    
    # Push frontend  
    echo_info "Pushing frontend image..."
    docker push ${REGISTRY}/${PROJECT_NAME}-frontend:${VERSION}
    
    echo_info "Images pushed successfully!"
}

# Deploy to Kubernetes
deploy_k8s() {
    echo_info "Deploying to Kubernetes..."
    
    # Check if kubectl is available
    if ! command -v kubectl &> /dev/null; then
        echo_error "kubectl not found. Please install kubectl and try again."
        exit 1
    fi
    
    # Apply manifests
    kubectl apply -f k8s/
    
    echo_info "Kubernetes deployment completed!"
    echo_info "Check status with: kubectl get pods -n mern-auth-app"
}

# Show logs
show_logs() {
    echo_info "Showing application logs..."
    docker-compose logs -f
}

# Clean up
cleanup() {
    echo_info "Cleaning up Docker resources..."
    
    # Stop containers
    docker-compose down
    docker-compose -f docker-compose.prod.yml down
    
    # Remove unused images
    docker image prune -f
    
    # Remove unused volumes
    docker volume prune -f
    
    echo_info "Cleanup completed!"
}

# Main script logic
main() {
    check_docker
    
    case "${1:-dev}" in
        dev)
            deploy_dev
            ;;
        prod)
            deploy_prod
            ;;
        build)
            build_images
            ;;
        push)
            build_images
            push_images
            ;;
        k8s)
            deploy_k8s
            ;;
        logs)
            show_logs
            ;;
        cleanup)
            cleanup
            ;;
        *)
            echo "Usage: $0 {dev|prod|build|push|k8s|logs|cleanup}"
            echo ""
            echo "Commands:"
            echo "  dev     - Start development environment"
            echo "  prod    - Start production environment"
            echo "  build   - Build Docker images"
            echo "  push    - Build and push images to registry"
            echo "  k8s     - Deploy to Kubernetes"
            echo "  logs    - Show application logs"
            echo "  cleanup - Clean up Docker resources"
            exit 1
            ;;
    esac
}

main "$@"
