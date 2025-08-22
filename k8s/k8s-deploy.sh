#!/bin/bash

# Kubernetes deployment script for MERN Auth App
# Usage: ./k8s-deploy.sh [deploy|delete|status|logs|port-forward]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="mern-auth"
APP_NAME="mern-auth-app"

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo_header() {
    echo -e "${BLUE}[K8S]${NC} $1"
}

# Check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        echo_error "kubectl not found. Please install kubectl and try again."
        exit 1
    fi
    
    # Check if kubectl can connect to cluster
    if ! kubectl cluster-info &> /dev/null; then
        echo_error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
        exit 1
    fi
    
    echo_info "Connected to Kubernetes cluster: $(kubectl config current-context)"
}

# Build Docker images if needed
build_images() {
    echo_header "Building Docker images..."
    
    # Check if images exist
    if ! docker images | grep -q "mern-auth-app-backend"; then
        echo_info "Building backend image..."
        docker build -t mern-auth-app-backend:latest ./backend
    fi
    
    if ! docker images | grep -q "mern-auth-app-frontend"; then
        echo_info "Building frontend image..."
        docker build -t mern-auth-app-frontend:latest ./frontend
        docker tag mern-auth-app-frontend:latest bhaskar093/mern-auth-app-frontend:latest
        docker push bhaskar093/mern-auth-app-frontend:latest
    fi
    
    echo_info "Docker images ready!"
}

# Load images to cluster (for local development)
load_images() {
    echo_header "Loading images to cluster..."
    
    # For minikube
    if command -v minikube &> /dev/null && minikube status &> /dev/null; then
        echo_info "Loading images to minikube..."
        minikube image load bhaskar093/mern-auth-app-backend:latest
        minikube image load bhaskar093/mern-auth-app-frontend:latest
    
    # For kind
    elif command -v kind &> /dev/null; then
        echo_info "Loading images to kind cluster..."
        kind load docker-image bhaskar093/mern-auth-app-backend:latest
        kind load docker-image bhaskar093/mern-auth-app-frontend:latest
    
    # For other local clusters
    else
        echo_warn "Unable to automatically load images. Make sure images are available in your cluster."
    fi
}

# Deploy application to Kubernetes
deploy_app() {
    echo_header "Deploying MERN Auth App to Kubernetes..."
    
    # Create k8s directory if it doesn't exist
    mkdir -p k8s
    
    # Apply all manifests
    echo_info "Applying Kubernetes manifests..."
    kubectl apply -f namespace.yaml
    kubectl apply -f secrets.yaml
    kubectl apply -f mongodb-statefulset.yaml
    kubectl apply -f backend-deployment.yaml
    kubectl apply -f frontend-deployment.yaml
    kubectl apply -f nginx-deployment.yaml
    kubectl apply -f ingress.yaml
    
    echo_info "Waiting for deployments to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment --all -n $NAMESPACE
    
    echo_info "✅ Application deployed successfully!"
    echo_info "🌐 Access your app:"
    echo_info "   - Minikube: minikube service nginx -n $NAMESPACE"
    echo_info "   - Port Forward: kubectl port-forward svc/nginx 8080:80 -n $NAMESPACE"
    echo_info "   - Ingress: kubectl get ingress -n $NAMESPACE"
}

# Delete application from Kubernetes
delete_app() {
    echo_header "Deleting MERN Auth App from Kubernetes..."
    
    echo_warn "This will delete all resources in namespace: $NAMESPACE"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kubectl delete namespace $NAMESPACE
        echo_info "✅ Application deleted successfully!"
    else
        echo_info "❌ Deletion cancelled."
    fi
}

# Show application status
show_status() {
    echo_header "MERN Auth App Status"
    
    echo_info "Namespace: $NAMESPACE"
    kubectl get namespace $NAMESPACE 2>/dev/null || echo_warn "Namespace not found"
    
    echo_info "\n📦 Pods:"
    kubectl get pods -n $NAMESPACE -o wide 2>/dev/null || echo_warn "No pods found"
    
    echo_info "\n🌐 Services:"
    kubectl get services -n $NAMESPACE 2>/dev/null || echo_warn "No services found"
    
    echo_info "\n🚀 Deployments:"
    kubectl get deployments -n $NAMESPACE 2>/dev/null || echo_warn "No deployments found"
    
    echo_info "\n📊 StatefulSets:"
    kubectl get statefulsets -n $NAMESPACE 2>/dev/null || echo_warn "No statefulsets found"
    
    echo_info "\n🔄 HPA:"
    kubectl get hpa -n $NAMESPACE 2>/dev/null || echo_warn "No HPA found"
    
    echo_info "\n🌍 Ingress:"
    kubectl get ingress -n $NAMESPACE 2>/dev/null || echo_warn "No ingress found"
}

# Show logs
show_logs() {
    echo_header "Application Logs"
    
    echo_info "Available pods:"
    kubectl get pods -n $NAMESPACE --no-headers -o custom-columns=":metadata.name" 2>/dev/null
    
    echo_info "\n🔍 Recent logs from all pods:"
    
    # Backend logs
    echo_info "\n--- Backend Logs ---"
    kubectl logs -l app=backend --tail=20 -n $NAMESPACE 2>/dev/null || echo_warn "No backend logs"
    
    # Frontend logs  
    echo_info "\n--- Frontend Logs ---"
    kubectl logs -l app=frontend --tail=20 -n $NAMESPACE 2>/dev/null || echo_warn "No frontend logs"
    
    # MongoDB logs
    echo_info "\n--- MongoDB Logs ---"
    kubectl logs -l app=mongodb --tail=20 -n $NAMESPACE 2>/dev/null || echo_warn "No mongodb logs"
    
    # Nginx logs
    echo_info "\n--- Nginx Logs ---"
    kubectl logs -l app=nginx --tail=20 -n $NAMESPACE 2>/dev/null || echo_warn "No nginx logs"
}

# Port forward for local access
port_forward() {
    echo_header "Port Forwarding"
    echo_info "Setting up port forwarding to access your application locally..."
    echo_info "Application will be available at: http://localhost:8080"
    echo_info "Press Ctrl+C to stop port forwarding"
    
    kubectl port-forward svc/nginx 8080:80 -n $NAMESPACE
}

# Scale application
scale_app() {
    echo_header "Scaling Application"
    
    echo_info "Current replica counts:"
    kubectl get deployments -n $NAMESPACE -o custom-columns="NAME:.metadata.name,REPLICAS:.spec.replicas,READY:.status.readyReplicas"
    
    echo_info "\nScaling options:"
    echo "1. Scale backend"
    echo "2. Scale frontend" 
    echo "3. Scale nginx"
    echo "4. Auto-scale backend (enable HPA)"
    
    read -p "Choose option (1-4): " -n 1 -r
    echo
    
    case $REPLY in
        1)
            read -p "Enter backend replicas count: " replicas
            kubectl scale deployment backend --replicas=$replicas -n $NAMESPACE
            ;;
        2)
            read -p "Enter frontend replicas count: " replicas
            kubectl scale deployment frontend --replicas=$replicas -n $NAMESPACE
            ;;
        3)
            read -p "Enter nginx replicas count: " replicas
            kubectl scale deployment nginx --replicas=$replicas -n $NAMESPACE
            ;;
        4)
            kubectl autoscale deployment backend --cpu-percent=70 --min=2 --max=10 -n $NAMESPACE
            echo_info "Auto-scaling enabled for backend"
            ;;
        *)
            echo_warn "Invalid option"
            ;;
    esac
}

# Test application endpoints
test_app() {
    echo_header "Testing Application"
    
    # Port forward in background
    kubectl port-forward svc/nginx 8081:80 -n $NAMESPACE &
    PF_PID=$!
    sleep 5
    
    echo_info "Testing endpoints..."
    
    # Test health endpoint
    if curl -s http://localhost:8081/health > /dev/null; then
        echo_info "✅ Health endpoint working"
    else
        echo_error "❌ Health endpoint failed"
    fi
    
    # Test main page
    if curl -s http://localhost:8081/ | grep -q "React App"; then
        echo_info "✅ Frontend working"
    else
        echo_error "❌ Frontend failed"
    fi
    
    # Test API
    if curl -s http://localhost:8081/api/health > /dev/null; then
        echo_info "✅ Backend API working"
    else
        echo_error "❌ Backend API failed"
    fi
    
    # Kill port forward
    kill $PF_PID 2>/dev/null
    
    echo_info "🎯 Test complete! Use 'kubectl port-forward svc/nginx 8080:80 -n $NAMESPACE' to access your app"
}

# Main script logic
main() {
    check_kubectl
    
    case "${1:-help}" in
        deploy)
            build_images
            load_images
            deploy_app
            ;;
        delete)
            delete_app
            ;;
        status)
            show_status
            ;;
        logs)
            show_logs
            ;;
        port-forward|pf)
            port_forward
            ;;
        scale)
            scale_app
            ;;
        test)
            test_app
            ;;
        help|*)
            echo "Usage: $0 {deploy|delete|status|logs|port-forward|scale|test}"
            echo ""
            echo "Commands:"
            echo "  deploy       - Build images and deploy application to Kubernetes"
            echo "  delete       - Delete application from Kubernetes"
            echo "  status       - Show application status"
            echo "  logs         - Show application logs"
            echo "  port-forward - Port forward to access application locally"
            echo "  scale        - Scale application components"
            echo "  test         - Test application endpoints"
            echo ""
            echo "Examples:"
            echo "  $0 deploy                    # Deploy the application"
            echo "  $0 status                    # Check application status"
            echo "  $0 port-forward              # Access app at http://localhost:8080"
            echo "  $0 logs                      # View application logs"
            exit 1
            ;;
    esac
}

main "$@"