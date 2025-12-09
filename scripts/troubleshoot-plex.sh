#!/bin/bash
# Troubleshooting script for Plex connection issues

echo "==================================================="
echo "Plex Connection Troubleshooting"
echo "==================================================="
echo ""

echo "Step 1: Checking if Docker is installed..."
echo "---------------------------------------------------"
if command -v docker &> /dev/null; then
    echo "✓ Docker is installed"
    docker --version
else
    echo "❌ Docker is NOT installed"
    echo ""
    echo "Install Docker:"
    echo "  curl -fsSL https://get.docker.com -o get-docker.sh"
    echo "  sudo sh get-docker.sh"
    exit 1
fi
echo ""

echo "Step 2: Checking if Docker Compose is installed..."
echo "---------------------------------------------------"
if command -v docker-compose &> /dev/null; then
    echo "✓ Docker Compose is installed"
    docker-compose --version
elif docker compose version &> /dev/null; then
    echo "✓ Docker Compose (plugin) is installed"
    docker compose version
else
    echo "❌ Docker Compose is NOT installed"
    echo ""
    echo "Install Docker Compose:"
    echo "  sudo curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)\" -o /usr/local/bin/docker-compose"
    echo "  sudo chmod +x /usr/local/bin/docker-compose"
    exit 1
fi
echo ""

echo "Step 3: Checking if containers are running..."
echo "---------------------------------------------------"
docker-compose ps 2>/dev/null || docker compose ps 2>/dev/null
echo ""

echo "Step 4: Checking Plex container specifically..."
echo "---------------------------------------------------"
if docker ps | grep -q plex; then
    echo "✓ Plex container is running"
    docker ps | grep plex
else
    echo "❌ Plex container is NOT running"
    echo ""
    echo "Starting services..."
    docker-compose up -d 2>/dev/null || docker compose up -d 2>/dev/null
fi
echo ""

echo "Step 5: Checking Plex logs for errors..."
echo "---------------------------------------------------"
echo "Last 20 lines from Plex:"
docker-compose logs --tail=20 plex 2>/dev/null || docker compose logs --tail=20 plex 2>/dev/null
echo ""

echo "Step 6: Checking if port 32400 is accessible..."
echo "---------------------------------------------------"
if command -v netstat &> /dev/null; then
    netstat -tulpn 2>/dev/null | grep 32400 || echo "Port 32400 not found in netstat"
elif command -v ss &> /dev/null; then
    ss -tulpn 2>/dev/null | grep 32400 || echo "Port 32400 not found in ss"
else
    echo "Cannot check ports (netstat/ss not available)"
fi
echo ""

echo "Step 7: Testing connection to Plex..."
echo "---------------------------------------------------"
if command -v curl &> /dev/null; then
    echo "Testing http://localhost:32400..."
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:32400 2>/dev/null | grep -q "200\|301"; then
        echo "✓ Plex is responding on port 32400"
    else
        echo "❌ Plex is not responding"
    fi
else
    echo "curl not available to test connection"
fi
echo ""

echo "Step 8: Checking your server's IP address..."
echo "---------------------------------------------------"
echo "Your local IP addresses:"
hostname -I 2>/dev/null || ip addr show 2>/dev/null | grep "inet " | awk '{print $2}'
echo ""

echo "==================================================="
echo "Troubleshooting Summary"
echo "==================================================="
echo ""
echo "NEXT STEPS:"
echo ""
echo "1. If Docker/Docker Compose not installed:"
echo "   → Install them first (see instructions above)"
echo ""
echo "2. If containers aren't running:"
echo "   → Run: docker-compose up -d"
echo ""
echo "3. If Plex container has errors:"
echo "   → Check full logs: docker-compose logs plex"
echo "   → Try rebuild: docker-compose up -d --build"
echo ""
echo "4. Try accessing Plex via your local IP:"
echo "   → http://YOUR_IP_ADDRESS:32400/web"
echo "   → Replace YOUR_IP_ADDRESS with one shown in Step 8"
echo ""
echo "5. If on a remote server (not localhost):"
echo "   → Access via: http://SERVER_IP:32400/web"
echo "   → Make sure firewall allows port 32400"
echo ""
