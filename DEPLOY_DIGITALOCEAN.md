# DigitalOcean One-Click Deploy

Este guia mostra como fazer deploy rápido do projeto em um Droplet do DigitalOcean.

## Opção 1: Deploy Automatizado (Recomendado)

### Passo 1: Criar Droplet

1. Acesse [DigitalOcean Dashboard](https://cloud.digitalocean.com)
2. Clique em "Create" → "Droplets"
3. Escolha:
   - **Image**: Ubuntu 22.04 LTS
   - **Size**: 4GB RAM / 2 vCPUs (mínimo recomendado)
   - **Region**: Escolha a mais próxima
   - **Authentication**: SSH Key (recomendado)

### Passo 2: Conectar e Executar Script

```bash
ssh root@seu_droplet_ip

# Baixar e executar script de deploy
curl -fsSL https://raw.githubusercontent.com/guicybercode/potential-adventure/main/deploy-digitalocean.sh | bash
```

Ou manualmente:

```bash
ssh root@seu_droplet_ip
git clone https://github.com/guicybercode/potential-adventure.git
cd potential-adventure
chmod +x deploy-digitalocean.sh
./deploy-digitalocean.sh
```

## Opção 2: Deploy Manual Passo a Passo

### 1. Preparar Servidor

```bash
ssh root@seu_droplet_ip

# Atualizar sistema
apt update && apt upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Instalar Docker Compose
apt-get install -y docker-compose-plugin

# Instalar Git
apt-get install -y git
```

### 2. Clonar Repositório

```bash
git clone https://github.com/guicybercode/potential-adventure.git
cd potential-adventure
```

### 3. Configurar Firewall

```bash
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP (para Nginx)
ufw allow 443/tcp   # HTTPS
ufw allow 4000/tcp  # Phoenix App
ufw allow 9090/tcp  # Prometheus
ufw allow 3000/tcp  # Grafana
ufw enable
```

### 4. Iniciar Serviços

```bash
docker compose up -d
```

### 5. Verificar Status

```bash
docker compose ps
docker compose logs -f app
```

## Configuração para Produção

### 1. Configurar Variáveis de Ambiente

Crie arquivo `.env`:

```bash
cat > .env << EOF
PHX_HOST=seu-dominio.com
SECRET_KEY_BASE=$(openssl rand -base64 64)
KAFKA_BROKERS=kafka:9092
PORT=4000
EOF
```

Atualize `docker-compose.yml` para usar `.env`:

```yaml
services:
  app:
    env_file:
      - .env
```

### 2. Configurar Nginx como Reverse Proxy

```bash
apt-get install -y nginx

cat > /etc/nginx/sites-available/realtime-processor << 'EOF'
server {
    listen 80;
    server_name seu-dominio.com;

    location / {
        proxy_pass http://localhost:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

ln -s /etc/nginx/sites-available/realtime-processor /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
```

### 3. Configurar SSL com Let's Encrypt

```bash
apt-get install -y certbot python3-certbot-nginx
certbot --nginx -d seu-dominio.com
```

### 4. Configurar Grafana (Primeira Vez)

Acesse `http://seu-droplet-ip:3000`:
- Usuário: `admin`
- Senha: `admin` (altere na primeira vez)

## Monitoramento

### Ver Logs

```bash
# Todos os serviços
docker compose logs -f

# Apenas aplicação
docker compose logs -f app

# Apenas Kafka
docker compose logs -f kafka
```

### Verificar Recursos

```bash
docker stats
df -h
free -h
```

### Reiniciar Serviços

```bash
docker compose restart app
docker compose restart kafka
```

## Troubleshooting

### Serviços não iniciam

```bash
docker compose down
docker compose up -d
docker compose logs
```

### Kafka não conecta

```bash
docker compose logs kafka
docker exec -it kafka kafka-topics --list --bootstrap-server localhost:9092
```

### Porta já em uso

```bash
netstat -tulpn | grep :4000
# Ou altere a porta no docker-compose.yml
```

### Falta de memória

```bash
# Ver uso atual
free -h

# Se necessário, aumente o droplet ou ajuste limites no docker-compose.yml
```

## Backup

### Backup Kafka Data

```bash
docker exec kafka tar czf /tmp/kafka-backup.tar.gz /var/lib/kafka/data
docker cp kafka:/tmp/kafka-backup.tar.gz ./backup-$(date +%Y%m%d).tar.gz
```

### Backup Grafana

```bash
docker exec grafana tar czf /tmp/grafana-backup.tar.gz /var/lib/grafana
docker cp grafana:/tmp/grafana-backup.tar.gz ./grafana-backup-$(date +%Y%m%d).tar.gz
```

## Escalabilidade

Para maior tráfego, considere:

1. **DigitalOcean Managed Kafka** - Substituir Kafka self-hosted
2. **Load Balancer** - Para múltiplas instâncias da app
3. **Managed Database** - Para persistência de dados
4. **Kubernetes** - Para orquestração avançada

## Custos Estimados

- **Droplet 4GB**: ~$24/mês
- **Droplet 8GB**: ~$48/mês (recomendado para produção)
- **Managed Kafka**: ~$15/mês (opcional)
- **Load Balancer**: ~$12/mês (opcional)

**Total básico**: ~$24-48/mês

## Segurança

- [ ] Alterar senha padrão do Grafana
- [ ] Configurar firewall (UFW)
- [ ] Usar SSH keys (desabilitar senha)
- [ ] Habilitar SSL/TLS
- [ ] Atualizações regulares: `apt update && apt upgrade`
- [ ] Monitorar logs para atividade suspeita
- [ ] Usar secrets management para dados sensíveis

## Próximos Passos

1. Configurar domínio e DNS
2. Habilitar SSL/TLS
3. Configurar backups automáticos
4. Configurar alertas de monitoramento
5. Revisar logs regularmente
6. Planejar escalabilidade conforme necessário
