#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   📊 Status do Sistema${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

cd "$PROJECT_DIR"

echo -e "${YELLOW}🔍 Phoenix Server:${NC}"
if pgrep -f "mix phx.server" > /dev/null; then
    echo -e "   ${GREEN}✓ Rodando${NC}"
    PHOENIX_PID=$(pgrep -f "mix phx.server")
    echo -e "   PID: ${PHOENIX_PID}"
else
    echo -e "   ${RED}✗ Parado${NC}"
fi
echo ""

echo -e "${YELLOW}🐳 Docker Containers:${NC}"
if docker-compose ps --quiet | grep -q .; then
    docker-compose ps
else
    echo -e "   ${RED}✗ Nenhum container rodando${NC}"
fi
echo ""

echo -e "${YELLOW}🌐 Testando Endpoints:${NC}"

if curl -s -o /dev/null -w "%{http_code}" http://localhost:4000 2>/dev/null | grep -q "200\|302"; then
    echo -e "   Phoenix (4000):     ${GREEN}✓ Acessível${NC}"
else
    echo -e "   Phoenix (4000):     ${RED}✗ Inacessível${NC}"
fi

if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null | grep -q "200\|302"; then
    echo -e "   Grafana (3000):     ${GREEN}✓ Acessível${NC}"
else
    echo -e "   Grafana (3000):     ${RED}✗ Inacessível${NC}"
fi

if curl -s -o /dev/null -w "%{http_code}" http://localhost:9090 2>/dev/null | grep -q "200\|302"; then
    echo -e "   Prometheus (9090):  ${GREEN}✓ Acessível${NC}"
else
    echo -e "   Prometheus (9090):  ${RED}✗ Inacessível${NC}"
fi

echo ""

if docker-compose ps --quiet kafka 2>/dev/null | grep -q .; then
    echo -e "${YELLOW}📡 Kafka:${NC}"
    if docker-compose logs kafka 2>/dev/null | grep -q "started (kafka.server.KafkaServer)"; then
        echo -e "   ${GREEN}✓ Rodando e pronto${NC}"
    else
        echo -e "   ${YELLOW}⏳ Iniciando...${NC}"
    fi
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

