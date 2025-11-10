#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   🚀 Elixir + Rust + Zig Real-Time Processing Pipeline${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

cd "$PROJECT_DIR"

echo -e "${YELLOW}📋 Verificando dependências...${NC}"

if ! command -v mix &> /dev/null; then
    echo -e "${RED}❌ Elixir não está instalado!${NC}"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker não está instalado!${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose não está instalado!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Todas as dependências estão instaladas${NC}\n"

echo -e "${YELLOW}📦 Instalando dependências Elixir...${NC}"
mix deps.get

echo -e "${YELLOW}🔨 Compilando projeto...${NC}"
mix compile

echo -e "${GREEN}✓ Projeto compilado com sucesso${NC}\n"

echo -e "${YELLOW}🐳 Iniciando serviços Docker...${NC}"
docker-compose up -d

echo -e "${GREEN}✓ Docker Compose iniciado${NC}\n"

echo -e "${YELLOW}⏳ Aguardando Kafka ficar pronto...${NC}"
for i in {1..30}; do
    if docker-compose logs kafka 2>/dev/null | grep -q "started (kafka.server.KafkaServer)"; then
        echo -e "${GREEN}✓ Kafka está pronto!${NC}\n"
        break
    fi
    echo -n "."
    sleep 2
    if [ $i -eq 30 ]; then
        echo -e "\n${YELLOW}⚠️  Kafka está demorando, mas vou continuar...${NC}\n"
    fi
done

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Serviços iniciados com sucesso!${NC}\n"
echo -e "${BLUE}📍 URLs disponíveis:${NC}"
echo -e "   🌐 Dashboard:     ${GREEN}http://localhost:4000${NC}"
echo -e "   📊 Grafana:       ${GREEN}http://localhost:3000${NC} (admin/admin)"
echo -e "   📈 Prometheus:    ${GREEN}http://localhost:9090${NC}"
echo -e "   🔍 Metrics API:   ${GREEN}http://localhost:4000/api/metrics${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${YELLOW}🚀 Iniciando Phoenix Server...${NC}"
echo -e "${YELLOW}   (Pressione Ctrl+C duas vezes para parar)${NC}\n"

sleep 2

exec mix phx.server

