# 🚀 Kubernetes Deployment for MERN Auth App

This directory contains Kubernetes manifests to deploy your MERN stack application on any Kubernetes cluster.

## 📁 Structure
```
k8s/
├── namespace.yaml          # Application namespace
├── mongodb-secret.yaml     # MongoDB credentials
├── mongodb-statefulset.yaml # MongoDB database
├── backend-deployment.yaml  # Express.js API
├── frontend-deployment.yaml # React app
├── nginx-deployment.yaml   # Reverse proxy
├── ingress.yaml            # External access
└── README.md               # This file
```

## 🚀 Quick Deployment

```bash
# Apply all manifests
kubectl apply -f k8s/

# Check deployment status
kubectl get pods -n mern-auth

# Get external access URL
kubectl get ingress -n mern-auth
```

## 📊 Monitor Your Application

```bash
# View all resources
kubectl get all -n mern-auth

# Check logs
kubectl logs -f deployment/backend -n mern-auth
kubectl logs -f deployment/frontend -n mern-auth

# Port forward for testing
kubectl port-forward svc/nginx 8080:80 -n mern-auth
```

## 🔧 Scaling Your Application

```bash
# Scale backend
kubectl scale deployment backend --replicas=3 -n mern-auth

# Scale frontend  
kubectl scale deployment frontend --replicas=2 -n mern-auth

# Auto-scaling (HPA)
kubectl autoscale deployment backend --cpu-percent=70 --min=2 --max=10 -n mern-auth
```

## 🌐 Access Your Application

- **Minikube**: `minikube service nginx -n mern-auth`
- **Cloud**: Use the external IP from `kubectl get ingress -n mern-auth`
- **Local**: `kubectl port-forward svc/nginx 8080:80 -n mern-auth`

## 🔒 Environment Variables

Update the secrets and config maps in the manifests with your production values:
- JWT secrets
- MongoDB credentials  
- API URLs
- CORS origins