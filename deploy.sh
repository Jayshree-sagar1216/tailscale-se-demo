#!/bin/bash
# deploy.sh — Tailscale Demo Environment Setup
# Deploys two private web services accessible only over Tailscale

set -e

echo "===> Starting Tailscale Demo Deployment"

# Stop and remove existing containers if any
docker rm -f internal-app private-api 2>/dev/null || true

# Run internal web app on port 3000
docker run -d \
  --name internal-app \
  --restart unless-stopped \
  -p 3000:80 \
  -v $(pwd)/internal-app:/usr/share/nginx/html:ro \
  nginx:alpine

# Run private API on port 5000
docker run -d \
  --name private-api \
  --restart unless-stopped \
  -p 5000:80 \
  -v $(pwd)/private-api:/usr/share/nginx/html:ro \
  nginx:alpine

echo ""
echo "===> Containers running:"
docker ps --format "table {{.Names}}\t{{.Ports}}\t{{.Status}}"

echo ""
echo "===> Tailscale IP:"
tailscale ip -4

echo ""
echo "===> Access your services at:"
echo "  http://$(tailscale ip -4):3000  — Internal Portal"
echo "  http://$(tailscale ip -4):5000  — Private API"
echo ""
echo "===> Deployment complete."
