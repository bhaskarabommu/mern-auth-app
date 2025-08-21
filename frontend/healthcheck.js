#!/bin/sh
# Frontend health check script
# Save as: frontend/healthcheck.sh

# Check if nginx is running and serving content
if wget --no-verbose --tries=1 --spider http://localhost/health 2>/dev/null; then
  echo "Frontend health check passed"
  exit 0
else
  echo "Frontend health check failed"
  exit 1
fi