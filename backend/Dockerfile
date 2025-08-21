# Backend Dockerfile
FROM node:18-alpine AS base

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Development stage
FROM base AS development
ENV NODE_ENV=development
RUN npm ci --include=dev
COPY . .
USER nodejs
EXPOSE 5000
CMD ["dumb-init", "npm", "run", "dev"]

# Production dependencies stage
FROM base AS deps
ENV NODE_ENV=production
RUN npm ci --omit=dev && npm cache clean --force

# Production stage
FROM base AS production
ENV NODE_ENV=production

# Copy production dependencies
COPY --from=deps --chown=nodejs:nodejs /app/node_modules ./node_modules

# Copy application code
COPY --chown=nodejs:nodejs . .

# Switch to non-root user
USER nodejs

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node healthcheck.js || exit 1

# Expose port
EXPOSE 5000

# Start application
CMD ["dumb-init", "node", "server.js"]