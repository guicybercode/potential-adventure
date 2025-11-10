#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   🛑 Parando Elixir + Rust + Zig Pipeline${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

cd "$PROJECT_DIR"

echo -e "${YELLOW}🔍 Procurando processos Phoenix...${NC}"
PHOENIX_PIDS=$(pgrep -f "mix phx.server" || true)

if [ -n "$PHOENIX_PIDS" ]; then
    echo -e "${YELLOW}🛑 Parando Phoenix Server...${NC}"
    echo "$PHOENIX_PIDS" | xargs kill -15 2>/dev/null || true
    sleep 2
    echo "$PHOENIX_PIDS" | xargs kill -9 2>/dev/null || true
    echo -e "${GREEN}✓ Phoenix Server parado${NC}\n"
else
    echo -e "${GREEN}✓ Phoenix Server não está rodando${NC}\n"
fi

echo -e "${YELLOW}🐳 Parando serviços Docker...${NC}"
docker-compose down

echo -e "${GREEN}✓ Docker Compose parado${NC}\n"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Todos os serviços foram parados!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

