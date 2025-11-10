# Comandos para Instalar Dependências no Debian

## Instalação Rápida (Script Automatizado)

```bash
sudo bash install-dependencies-debian.sh
```

## Instalação Manual (Comandos para Colar)

### 1. Atualizar Sistema

```bash
sudo apt-get update && sudo apt-get upgrade -y
```

### 2. Instalar Dependências Básicas

```bash
sudo apt-get install -y build-essential git curl wget unzip libssl-dev libncurses5-dev libwxgtk3.2-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev autoconf m4 libncurses-dev python3 python3-pip
```

### 3. Instalar Erlang/OTP 26

```bash
sudo apt-get install -y erlang-base erlang-dev erlang-parsetools erlang-xmerl erlang-tools
```

### 4. Instalar Elixir 1.17

```bash
ELIXIR_VERSION="1.17.0"
wget https://github.com/elixir-lang/elixir/releases/download/v${ELIXIR_VERSION}/Precompiled.zip
sudo unzip Precompiled.zip -d /usr/local/elixir
rm Precompiled.zip
echo 'export PATH="/usr/local/elixir/bin:$PATH"' | sudo tee -a /etc/profile
export PATH="/usr/local/elixir/bin:$PATH"
```

### 5. Instalar Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
export PATH="$HOME/.cargo/bin:$PATH"
```

### 6. Instalar Zig

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

### 7. Instalar Docker (Opcional mas Recomendado)

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh
sudo apt-get install -y docker-compose-plugin
```

### 8. Verificar Instalações

```bash
elixir --version
rustc --version
zig version
docker --version
```

## Comandos em Bloco Único (Para Colar Tudo de Uma Vez)

```bash
sudo apt-get update && sudo apt-get upgrade -y && \
sudo apt-get install -y build-essential git curl wget unzip libssl-dev libncurses5-dev libwxgtk3.2-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev autoconf m4 libncurses-dev python3 python3-pip && \
sudo apt-get install -y erlang-base erlang-dev erlang-parsetools erlang-xmerl erlang-tools && \
ELIXIR_VERSION="1.17.0" && \
wget https://github.com/elixir-lang/elixir/releases/download/v${ELIXIR_VERSION}/Precompiled.zip && \
sudo unzip Precompiled.zip -d /usr/local/elixir && \
rm Precompiled.zip && \
echo 'export PATH="/usr/local/elixir/bin:$PATH"' | sudo tee -a /etc/profile && \
export PATH="/usr/local/elixir/bin:$PATH" && \
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
source $HOME/.cargo/env && \
export PATH="$HOME/.cargo/bin:$PATH" && \
ZIG_VERSION="0.13.0" && \
ZIG_ARCH="x86_64" && \
wget https://ziglang.org/download/${ZIG_VERSION}/zig-linux-${ZIG_ARCH}-${ZIG_VERSION}.tar.xz && \
tar -xf zig-linux-${ZIG_ARCH}-${ZIG_VERSION}.tar.xz && \
sudo mv zig-linux-${ZIG_ARCH}-${ZIG_VERSION} /usr/local/zig && \
rm zig-linux-${ZIG_ARCH}-${ZIG_VERSION}.tar.xz && \
echo 'export PATH="/usr/local/zig:$PATH"' | sudo tee -a /etc/profile && \
export PATH="/usr/local/zig:$PATH" && \
curl -fsSL https://get.docker.com -o get-docker.sh && \
sudo sh get-docker.sh && \
rm get-docker.sh && \
sudo apt-get install -y docker-compose-plugin && \
echo "Instalação concluída! Execute 'source /etc/profile' e 'source \$HOME/.cargo/env' ou faça logout/login."
```

## Após Instalação

### Configurar Variáveis de Ambiente

```bash
source /etc/profile
source $HOME/.cargo/env
```

Ou adicione ao seu `~/.bashrc`:

```bash
echo 'export PATH="/usr/local/elixir/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="/usr/local/zig:$PATH"' >> ~/.bashrc
echo 'source $HOME/.cargo/env' >> ~/.bashrc
source ~/.bashrc
```

### Verificar Instalações

```bash
elixir --version
mix --version
rustc --version
cargo --version
zig version
docker --version
```

## Instalar Dependências do Projeto

Após instalar as ferramentas, clone o projeto e instale as dependências:

```bash
git clone https://github.com/guicybercode/potential-adventure.git
cd potential-adventure
mix deps.get
cd native/rust_processor && cargo build --release && cd ../..
```

## Troubleshooting

### Erlang não encontrado
```bash
which erl
# Se não encontrar, reinstale:
sudo apt-get install --reinstall erlang-base
```

### Elixir não encontrado
```bash
export PATH="/usr/local/elixir/bin:$PATH"
# Adicione ao ~/.bashrc permanentemente
```

### Rust não encontrado
```bash
source $HOME/.cargo/env
# Adicione ao ~/.bashrc permanentemente
```

### Zig não encontrado
```bash
export PATH="/usr/local/zig:$PATH"
# Adicione ao ~/.bashrc permanentemente
```

### Problemas de Permissão
```bash
sudo usermod -aG docker $USER
# Faça logout e login novamente
```

