# 🚀 MERN Auth App - Full-Stack Authentication System

A production-ready MERN (MongoDB, Express.js, React, Node.js) stack application with JWT authentication, fully containerized with Docker and automated deployment scripts.

## 🌟 Features

- **🔐 JWT Authentication**: Secure login/logout with JSON Web Tokens
- **👤 User Management**: Registration, profile management, role-based access
- **🐳 Docker Containerization**: Complete development and production environments
- **🌐 Nginx Reverse Proxy**: Load balancing and static file serving
- **📊 Health Monitoring**: Built-in health checks for all services
- **🔒 Security**: CORS, security headers, input validation
- **⚡ Production Optimized**: Minified builds, caching, compression
- **🚀 Automated Deployment**: One-command deployment scripts

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Nginx Proxy   │────│  React Frontend  │────│ Express Backend │
│   Port: 80      │    │   Port: 3000     │    │   Port: 5000    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                         │
                                                ┌─────────────────┐
                                                │    MongoDB      │
                                                │   Port: 27017   │
                                                └─────────────────┘
```

## 🛠️ Technology Stack

### **Frontend**
- **React 18** - Modern UI library
- **React Router** - Client-side routing
- **Axios** - HTTP client
- **JWT Decode** - Token handling
- **CSS3** - Styling

### **Backend**
- **Node.js** - Runtime environment
- **Express.js** - Web framework
- **MongoDB** - NoSQL database
- **Mongoose** - ODM for MongoDB
- **JSON Web Tokens** - Authentication
- **bcryptjs** - Password hashing
- **CORS** - Cross-origin resource sharing

### **DevOps & Infrastructure**
- **Docker & Docker Compose** - Containerization
- **Nginx** - Reverse proxy and static file server
- **Multi-stage Builds** - Optimized production images
- **Health Checks** - Service monitoring

## 📋 Prerequisites

- **Docker** (version 20.10+)
- **Docker Compose** (version 2.0+)
- **Node.js** (version 18+) - for local development only
- **Git** - version control

## 🚀 Quick Start

### **1. Clone the Repository**
```bash
git clone <your-repository-url>
cd mern-auth-app
```

### **2. Set Up Environment Variables**

The deployment script will automatically create a `.env` file for development. For production, create `.env.prod`:

```bash
# Production Environment Variables
NODE_ENV=production
PORT=5000
MONGODB_URI=mongodb://admin:admin123@mongodb:27017/mern_auth_db_prod?authSource=admin
JWT_SECRET=prod_your_super_secure_jwt_secret_here
CORS_ORIGIN=http://localhost
REACT_APP_API_URL=http://localhost
```

### **3. Deploy Development Environment**
```bash
# Make script executable
chmod +x deploy.sh

# Start development environment
./deploy.sh dev
```

### **4. Deploy Production Environment**
```bash
# Start production environment
./deploy.sh prod
```

## 🎯 Access Your Application

### **Development Mode**
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5000
- **MongoDB**: mongodb://localhost:27017

### **Production Mode**
- **Main Application**: http://localhost
- **Direct Frontend**: http://localhost:3000
- **Direct Backend**: http://localhost:5000

## 📁 Project Structure

```
mern-auth-app/
├── backend/                 # Express.js API
│   ├── middleware/         # Authentication, validation
│   ├── models/            # Mongoose schemas
│   ├── routes/            # API endpoints
│   ├── utils/             # Helper functions
│   ├── Dockerfile         # Backend container config
│   └── server.js          # Express server
├── frontend/               # React application
│   ├── src/
│   │   ├── components/    # React components
│   │   ├── pages/         # Page components
│   │   ├── services/      # API calls
│   │   └── utils/         # Helper functions
│   ├── public/            # Static assets
│   ├── Dockerfile         # Frontend container config
│   └── nginx.conf         # Nginx configuration
├── nginx/                  # Reverse proxy configuration
│   └── nginx.conf         # Proxy settings
├── docker-compose.yml      # Development environment
├── docker-compose.prod.yml # Production environment
├── deploy.sh              # Deployment automation
├── .env                   # Development variables
├── .env.prod              # Production variables
└── README.md              # This file
```

## 🔧 Deployment Commands

```bash
# Development environment
./deploy.sh dev

# Production environment
./deploy.sh prod

# View logs
./deploy.sh logs

# Build Docker images
./deploy.sh build

# Push to registry
./deploy.sh push

# Kubernetes deployment
./deploy.sh k8s

# Clean up resources
./deploy.sh cleanup
```

## 🔗 API Endpoints

### **Authentication**
```bash
POST /api/auth/register
POST /api/auth/login
POST /api/auth/logout
GET  /api/auth/profile
PUT  /api/auth/profile
```

### **Health Check**
```bash
GET /health
GET /api/health
```

### **Example API Usage**

**Register a new user:**
```bash
curl -X POST http://localhost/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com","password":"password123"}'
```

**Login:**
```bash
curl -X POST http://localhost/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john@example.com","password":"password123"}'
```

**Access protected route:**
```bash
curl -X GET http://localhost/api/auth/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## 🔒 Security Features

- **JWT Authentication** - Stateless token-based auth
- **Password Hashing** - bcrypt with salt rounds
- **CORS Configuration** - Cross-origin request handling
- **Input Validation** - Request data sanitization
- **Security Headers** - XSS, CSRF protection
- **Rate Limiting** - API request throttling
- **Environment Variables** - Sensitive data protection

## 🐳 Docker Configuration

### **Development vs Production**

| Feature | Development | Production |
|---------|-------------|------------|
| **Frontend** | React dev server | Nginx + built React |
| **Hot Reload** | ✅ Enabled | ❌ Disabled |
| **Source Maps** | ✅ Enabled | ❌ Disabled |
| **Minification** | ❌ Disabled | ✅ Enabled |
| **Caching** | ❌ Disabled | ✅ Enabled |
| **SSL** | HTTP | HTTP (HTTPS ready) |

### **Container Health Checks**

All services include health monitoring:
- **Backend**: HTTP endpoint check
- **Frontend**: Nginx status check  
- **MongoDB**: Database ping
- **Nginx**: HTTP response check

## 🔍 Troubleshooting

### **Common Issues**

**Port 80 already in use:**
```bash
# Stop Apache if running
sudo systemctl stop apache2

# Or use different port in docker-compose.prod.yml
ports:
  - "8080:80"
```

**MongoDB connection failed:**
```bash
# Check MongoDB container logs
docker logs mern-mongo-prod

# Verify connection string in .env.prod
MONGODB_URI=mongodb://admin:admin123@mongodb:27017/mern_auth_db_prod?authSource=admin
```

**Frontend build errors:**
```bash
# Clean Docker cache
docker system prune -a

# Rebuild frontend image
docker-compose -f docker-compose.prod.yml build frontend
```

### **Debugging Commands**

```bash
# Check container status
docker ps -a

# View container logs
docker logs mern-backend-prod
docker logs mern-frontend-prod
docker logs mern-nginx-prod
docker logs mern-mongo-prod

# Access container shell
docker exec -it mern-backend-prod sh

# Test API endpoints
curl http://localhost/api/health
curl http://localhost/health
```

## 🚀 Production Deployment

### **Cloud Platforms**

This application is ready for deployment on:
- **AWS** (ECS, EKS, Elastic Beanstalk)
- **Google Cloud** (GKE, Cloud Run)
- **Azure** (Container Instances, AKS)
- **DigitalOcean** (App Platform, Kubernetes)
- **Heroku** (with buildpacks)

### **SSL/HTTPS Setup**

For production with custom domain:

1. **Update .env.prod:**
```bash
CORS_ORIGIN=https://yourdomain.com
REACT_APP_API_URL=https://api.yourdomain.com
```

2. **Add SSL certificates to nginx config:**
```nginx
server {
    listen 443 ssl;
    ssl_certificate /etc/ssl/certs/cert.pem;
    ssl_certificate_key /etc/ssl/private/key.pem;
    # ... rest of config
}
```

## 📊 Monitoring & Logging

### **Built-in Monitoring**
- Container health checks
- API endpoint monitoring
- Nginx access/error logs
- Application-level logging

### **Production Monitoring Setup**
```bash
# Add to docker-compose.prod.yml
services:
  prometheus:
    image: prom/prometheus
    # ... configuration

  grafana:
    image: grafana/grafana
    # ... configuration
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### **Development Setup**

```bash
# Clone and setup
git clone <your-fork>
cd mern-auth-app

# Start development environment
./deploy.sh dev

# Make changes and test
# Your changes will auto-reload in development mode
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **MERN Stack Community** - For the amazing ecosystem
- **Docker** - For containerization made simple
- **Nginx** - For robust reverse proxy capabilities
- **MongoDB** - For flexible document storage
- **React Team** - For the incredible frontend framework

## 📞 Support

If you have any questions or issues:

1. **Check the troubleshooting section** above
2. **Review container logs** for error details
3. **Open an issue** with detailed error information
4. **Contact the maintainers** for additional support

## 🔄 Version History

- **v1.0.0** - Initial release with full MERN stack
- **v1.1.0** - Added Docker containerization
- **v1.2.0** - Production optimization and automation
- **v1.3.0** - Enhanced security and monitoring

---
K8s is work in progress...

**🎉 Happy Coding!** Build amazing applications with this production-ready MERN stack foundation.
