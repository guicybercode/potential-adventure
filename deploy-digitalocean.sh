#!/bin/bash

set -e

echo "=========================================="
echo "DigitalOcean Deployment Script"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root or with sudo"
    exit 1
fi

echo "Step 1: Updating system packages..."
apt-get update
apt-get upgrade -y

echo "Step 2: Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
else
    echo "Docker already installed"
fi

echo "Step 3: Installing Docker Compose..."
if ! command -v docker compose &> /dev/null; then
    apt-get install -y docker-compose-plugin
else
    echo "Docker Compose already installed"
fi

echo "Step 4: Installing Git..."
apt-get install -y git

echo "Step 5: Installing Nginx (optional, for reverse proxy)..."
apt-get install -y nginx

echo "Step 6: Setting up firewall..."
ufw --force enable
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 4000/tcp
ufw allow 9090/tcp
ufw allow 3000/tcp

echo "Step 7: Checking if repository exists..."
if [ ! -d "potential-adventure" ]; then
    echo "Cloning repository..."
    git clone https://github.com/guicybercode/potential-adventure.git
    cd potential-adventure
else
    echo "Repository already exists, updating..."
    cd potential-adventure
    git pull
fi

echo "Step 8: Building and starting services..."
docker compose build
docker compose up -d

echo "Step 9: Waiting for services to be ready..."
sleep 10

echo "Step 10: Checking service status..."
docker compose ps

echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Services:"
echo "  - Phoenix App: http://$(curl -s ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}'):4000"
echo "  - Grafana: http://$(curl -s ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}'):3000"
echo "  - Prometheus: http://$(curl -s ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}'):9090"
echo ""
echo "Useful commands:"
echo "  - View logs: docker compose logs -f"
echo "  - Stop services: docker compose down"
echo "  - Restart services: docker compose restart"
echo "  - Check status: docker compose ps"
echo ""

