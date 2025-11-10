# Comandos Corrigidos para Instalar Dependências no Debian

## Comando Único (Copiar e Colar Tudo)

```bash
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y build-essential git curl wget unzip libssl-dev libncurses5-dev libwxgtk3.2-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev autoconf m4 libncurses-dev python3 python3-pip && wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb && sudo dpkg -i erlang-solutions_2.0_all.deb && sudo apt-get update && sudo apt-get install -y esl-erlang elixir && rm erlang-solutions_2.0_all.deb && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && source $HOME/.cargo/env && export PATH="$HOME/.cargo/bin:$PATH" && ZIG_VERSION="0.13.0" && ZIG_ARCH="x86_64" && wget https://ziglang.org/download/${ZIG_VERSION}/zig-linux-${ZIG_ARCH}-${ZIG_VERSION}.tar.xz && tar -xf zig-linux-${ZIG_ARCH}-${ZIG_VERSION}.tar.xz && sudo mv zig-linux-${ZIG_ARCH}-${ZIG_VERSION} /usr/local/zig && rm zig-linux-${ZIG_ARCH}-${ZIG_VERSION}.tar.xz && echo 'export PATH="/usr/local/zig:$PATH"' | sudo tee -a /etc/profile && export PATH="/usr/local/zig:$PATH" && curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh && rm get-docker.sh && sudo apt-get install -y docker-compose-plugin && echo "Instalação concluída! Execute 'source /etc/profile' e 'source \$HOME/.cargo/env'"
```

## Passo a Passo (Método Corrigido)

### 1. Atualizar Sistema
```bash
sudo apt-get update && sudo apt-get upgrade -y
```

### 2. Instalar Dependências Básicas
```bash
sudo apt-get install -y build-essential git curl wget unzip libssl-dev libncurses5-dev libwxgtk3.2-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev autoconf m4 libncurses-dev python3 python3-pip
```

### 3. Instalar Erlang e Elixir (Método Oficial)
```bash
wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb
sudo dpkg -i erlang-solutions_2.0_all.deb
sudo apt-get update
sudo apt-get install -y esl-erlang elixir
rm erlang-solutions_2.0_all.deb
```

### 4. Instalar Rust
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
export PATH="$HOME/.cargo/bin:$PATH"
```

### 5. Instalar Zig
```bash
ZIG_VERSION="0.13.0"
ZIG_ARCH="x86_64"
wget https://ziglang.org/download/${ZIG_VERSION}/zig-linux-${ZIG_ARCH}-${ZIG_VERSION}.tar.xz
tar -xf zig-linux-${ZIG_ARCH}-${ZIG_VERSION}.tar.xz
sudo mv zig-linux-${ZIG_ARCH}-${ZIG_VERSION} /usr/local/zig
rm zig-linux-${ZIG_ARCH}-${ZIG_VERSION}.tar.xz
echo 'export PATH="/usr/local/zig:$PATH"' | sudo tee -a /etc/profile
export PATH="/usr/local/zig:$PATH"
```

### 6. Instalar Docker
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh
sudo apt-get install -y docker-compose-plugin
```

### 7. Configurar Variáveis de Ambiente
```bash
source /etc/profile
source $HOME/.cargo/env
```

### 8. Verificar Instalações
```bash
elixir --version
mix --version
rustc --version
cargo --version
zig version
docker --version
```

## Solução Rápida para o Erro 404

Se você já executou o script anterior e teve erro no Elixir, execute apenas:

```bash
wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb
sudo dpkg -i erlang-solutions_2.0_all.deb
sudo apt-get update
sudo apt-get install -y esl-erlang elixir
rm erlang-solutions_2.0_all.deb
elixir --version
```

Este método usa o repositório oficial do Erlang Solutions e sempre terá a versão mais recente disponível.

