#!/bin/bash

set -e

echo "=========================================="
echo "Instalando dependências para Debian"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Por favor, execute como root ou com sudo"
    exit 1
fi

echo "Atualizando sistema..."
apt-get update
apt-get upgrade -y

echo "Instalando dependências básicas..."
apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
    unzip \
    libssl-dev \
    libncurses5-dev \
    libwxgtk3.2-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libpng-dev \
    autoconf \
    m4 \
    libncurses-dev \
    python3 \
    python3-pip

echo "Instalando Erlang/OTP e Elixir via repositório oficial..."
wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb
dpkg -i erlang-solutions_2.0_all.deb || true
apt-get update
apt-get install -y esl-erlang elixir
rm -f erlang-solutions_2.0_all.deb

echo "Instalando Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
if [ -f "$HOME/.cargo/env" ]; then
    source $HOME/.cargo/env
fi
export PATH="$HOME/.cargo/bin:$PATH"

echo "Instalando Zig..."
ZIG_VERSION="0.13.0"
ZIG_ARCH="x86_64"
wget -q https://ziglang.org/download/${ZIG_VERSION}/zig-linux-${ZIG_ARCH}-${ZIG_VERSION}.tar.xz
tar -xf zig-linux-${ZIG_ARCH}-${ZIG_VERSION}.tar.xz
mv zig-linux-${ZIG_ARCH}-${ZIG_VERSION} /usr/local/zig
rm zig-linux-${ZIG_ARCH}-${ZIG_VERSION}.tar.xz
echo 'export PATH="/usr/local/zig:$PATH"' >> /etc/profile
export PATH="/usr/local/zig:$PATH"

echo "Instalando Docker..."
if command -v docker &> /dev/null; then
    echo "Docker já está instalado"
else
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
fi

echo "Instalando Docker Compose..."
apt-get install -y docker-compose-plugin

echo "Verificando instalações..."
echo ""
echo "Erlang:"
erl -version 2>/dev/null || echo "Erlang instalado"
echo ""
echo "Elixir:"
elixir --version
echo ""
echo "Rust:"
$HOME/.cargo/bin/rustc --version 2>/dev/null || echo "Rust instalado (execute 'source \$HOME/.cargo/env')"
echo ""
echo "Zig:"
/usr/local/zig/zig version
echo ""
echo "Docker:"
docker --version
docker compose version

echo "=========================================="
echo "Instalação concluída!"
echo "=========================================="
echo ""
echo "IMPORTANTE: Para usar as ferramentas em uma nova sessão:"
echo "  1. Execute: source /etc/profile"
echo "  2. Execute: source \$HOME/.cargo/env"
echo "  3. Ou faça logout e login novamente"
echo ""
