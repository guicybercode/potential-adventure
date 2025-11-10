# 🚀 Guia Rápido de Uso

## Iniciar o Servidor

```bash
./start.sh
```

Este script irá:
- ✓ Verificar dependências
- ✓ Instalar pacotes Elixir
- ✓ Compilar o projeto (Elixir + Rust NIFs)
- ✓ Iniciar Docker Compose (Kafka, Prometheus, Grafana)
- ✓ Aguardar Kafka ficar pronto
- ✓ Iniciar o Phoenix Server

## Verificar Status

```bash
./status.sh
```

Mostra:
- Status do Phoenix Server
- Status dos containers Docker
- Acessibilidade dos endpoints
- Status do Kafka

## Parar o Servidor

```bash
./stop.sh
```

Para:
- Phoenix Server
- Todos os containers Docker

## 🌐 Acessar as Interfaces

Após iniciar com `./start.sh`:

| Serviço | URL | Descrição |
|---------|-----|-----------|
| **Dashboard** | http://localhost:4000 | LiveView em tempo real |
| **API Métricas** | http://localhost:4000/api/metrics | Endpoint Prometheus |
| **API Agregações** | http://localhost:4000/api/aggregations/:symbol | Dados OHLC |
| **API Anomalias** | http://localhost:4000/api/anomalies/:symbol | Detecção de anomalias |
| **Grafana** | http://localhost:3000 | Dashboards (admin/admin) |
| **Prometheus** | http://localhost:9090 | Métricas do sistema |

## 🧪 Testar APIs

```bash
# Ver métricas
curl http://localhost:4000/api/metrics

# Ver agregações de um símbolo
curl http://localhost:4000/api/aggregations/BTCUSD

# Ver anomalias de um símbolo
curl http://localhost:4000/api/anomalies/AAPL
```

## ⚡ Comandos Úteis

```bash
# Ver logs do Docker
docker-compose logs -f

# Ver logs apenas do Kafka
docker-compose logs -f kafka

# Ver logs do gerador de dados
docker-compose logs -f data-generator

# Recompilar NIFs Rust
cd native/rust_processor
cargo build --release
cd ../..
mix compile --force

# Rodar testes
mix test

# Rodar benchmarks
mix run benchmark/run_benchmarks.exs
```

## 🔧 Troubleshooting

### Porta 4000 já está em uso
```bash
sudo lsof -ti:4000 | xargs kill -9
./start.sh
```

### Kafka não conecta
```bash
# Espere 30 segundos e verifique
docker-compose logs kafka

# Deve mostrar: "started (kafka.server.KafkaServer)"
```

### Recompilar tudo do zero
```bash
./stop.sh
mix clean
mix deps.clean --all
mix deps.get
./start.sh
```

### Remover tudo e começar limpo
```bash
./stop.sh
docker-compose down -v
git pull
mix deps.get
./start.sh
```

## 📚 Estrutura do Projeto

```
├── start.sh              # Inicia tudo
├── stop.sh               # Para tudo
├── status.sh             # Verifica status
├── docker-compose.yml    # Configuração Docker
├── apps/
│   └── realtime_processor/  # Aplicação Phoenix
├── native/
│   ├── rust_processor/   # NIFs Rust
│   └── zig_nifs/         # NIFs Zig
└── benchmark/            # Scripts de benchmark
```

## 🎯 Próximos Passos

1. **Explorar o Dashboard**: http://localhost:4000
2. **Visualizar no Grafana**: http://localhost:3000
3. **Testar as APIs REST**: Ver seção "Testar APIs" acima
4. **Rodar Benchmarks**: `mix run benchmark/run_benchmarks.exs`
5. **Ver Métricas**: http://localhost:4000/api/metrics

---

**Dica**: Use sempre `./status.sh` para verificar se tudo está rodando corretamente!

