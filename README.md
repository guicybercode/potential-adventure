# Multi-Language Real-Time Data Processing Pipeline

A high-performance real-time data processing pipeline combining Elixir, Rust, and Zig for processing financial trading data from Kafka with full observability and fault tolerance.

## Architecture Overview

```
┌─────────┐
│  Kafka  │───┐
└─────────┘   │
              ▼
    ┌─────────────────┐
    │  Broadway (Elixir)│
    │  Kafka Consumer  │
    └────────┬──────────┘
             │
    ┌────────┴──────────┐
    │                  │
    ▼                  ▼
┌─────────┐      ┌─────────┐
│ Zig NIF │      │Rust NIF │
│ Parser  │      │Aggregate│
└─────────┘      └─────────┘
    │                  │
    └────────┬──────────┘
             ▼
    ┌─────────────────┐
    │  Phoenix API    │
    │  LiveView UI    │
    └─────────────────┘
             │
    ┌────────┴──────────┐
    │                  │
    ▼                  ▼
┌─────────┐      ┌─────────┐
│Prometheus│      │ Grafana │
└─────────┘      └─────────┘
```

## Prerequisites

- Erlang/OTP 26.0+
- Elixir 1.17+
- Rust 1.75+
- Zig 0.13+
- Docker and Docker Compose
- Kafka (or use Docker Compose)

## Quick Start with Docker

```bash
docker-compose up -d
```

This will start:
- Kafka and Zookeeper
- Prometheus
- Grafana (http://localhost:3000, admin/admin)
- Data generator
- Phoenix application (http://localhost:4000)

## Manual Installation

### 1. Install Dependencies

```bash
mix deps.get
cd native/rust_processor && cargo build --release
```

### 2. Start Kafka

```bash
docker-compose up -d kafka zookeeper
```

### 3. Create Kafka Topics

```bash
docker exec -it kafka kafka-topics --create --topic trades --bootstrap-server localhost:9092
docker exec -it kafka kafka-topics --create --topic orders --bootstrap-server localhost:9092
```

### 4. Start the Application

```bash
mix phx.server
```

### 5. Generate Test Data

```bash
python generator.py
```

## Project Structure

```
elixir_rust_zig/
├── apps/
│   └── realtime_processor/     # Phoenix + Broadway app
│       ├── lib/
│       │   ├── realtime_processor/
│       │   │   ├── pipeline/   # Broadway pipeline
│       │   │   ├── metrics.ex  # Telemetry metrics
│       │   │   ├── rust_processor.ex
│       │   │   └── zig_nifs.ex
│       │   └── realtime_processor_web/
│       │       ├── controllers/
│       │       └── live/
│       └── mix.exs
├── native/
│   ├── rust_processor/         # Rust aggregation/anomaly detection
│   │   ├── src/
│   │   │   ├── lib.rs
│   │   │   ├── aggregation.rs
│   │   │   └── anomaly.rs
│   │   └── Cargo.toml
│   └── zig_nifs/               # Zig binary parsing
│       ├── src/
│       │   ├── nif.zig
│       │   ├── parser.zig
│       │   └── checksum.zig
│       └── build.zig
├── benchmark/                  # Performance benchmarks
├── docker-compose.yml
├── Dockerfile
├── .github/workflows/ci.yml
└── .gitlab-ci.yml
```

## Language Responsibilities

### Elixir (Phoenix + Broadway)
- **Ingestion**: Kafka message consumption via Broadway
- **Orchestration**: Coordinates Rust and Zig NIF calls
- **API**: Phoenix HTTP endpoints and LiveView dashboard
- **Supervision**: Fault-tolerant process supervision
- **Telemetry**: Metrics collection and OpenTelemetry tracing

### Rust (Processing Layer)
- **Aggregation**: Sliding window OHLC aggregation
- **Anomaly Detection**: Z-score based outlier detection
- **Performance**: Optimized for complex data transformations

### Zig (Hot Path)
- **Binary Parsing**: FIX protocol message parsing
- **Checksum**: CRC32 calculation with minimal latency
- **Performance**: Maximum performance for critical paths

## API Endpoints

### GET /api/metrics
Returns Prometheus metrics in text format.

### GET /api/aggregations/:symbol
Returns OHLC aggregations for a given symbol.

Example:
```bash
curl http://localhost:4000/api/aggregations/BTCUSD
```

### GET /api/anomalies/:symbol
Returns detected anomalies for a given symbol.

Example:
```bash
curl http://localhost:4000/api/anomalies/BTCUSD
```

## Data Format

### Trade Message (JSON)
```json
{
  "symbol": "BTCUSD",
  "price": 45000.50,
  "quantity": 0.25,
  "timestamp": 1699632000000,
  "side": "buy"
}
```

### FIX Message (Binary)
FIX protocol messages use SOH (0x01) as field delimiter:
```
8=FIX.4.2<SOH>9=178<SOH>35=D<SOH>...
```

## Benchmarks

Run benchmarks:
```bash
mix run benchmark/run_benchmarks.exs
```

Results are saved to `benchmark/results.md`.

## Observability

### Prometheus Metrics
- `realtime_processor_messages_total` - Total messages processed
- `realtime_processor_anomalies_total` - Total anomalies detected
- `realtime_processor_batch_duration_microseconds` - Batch processing latency
- `realtime_processor_message_duration_microseconds` - Per-message latency

### Grafana Dashboard
Access at http://localhost:3000 (admin/admin)

### Logging
Structured JSON logging configured via `logger_json`.

## Development

### Running Tests
```bash
mix test
cd native/rust_processor && cargo test
```

### Formatting
```bash
mix format
cd native/rust_processor && cargo fmt
cd native/zig_nifs && zig fmt .
```

### Linting
```bash
mix credo
```

## CI/CD

### GitHub Actions
Automated testing, formatting checks, and benchmarks on push/PR.

### GitLab CI
Similar pipeline with Docker image building for main/master branches.

## Performance Considerations

- **Zig NIFs**: Used for ultra-low latency binary parsing (< 1μs)
- **Rust NIFs**: Used for complex aggregations with predictable performance
- **Elixir**: Handles concurrency, fault tolerance, and orchestration
- **Broadway**: Provides backpressure and batching for Kafka consumption

## Troubleshooting

### NIF Compilation Issues
Ensure Rust and Zig toolchains are properly installed:
```bash
rustc --version
zig version
```

### Kafka Connection Issues
Verify Kafka is running:
```bash
docker-compose ps
docker logs kafka
```

### Port Conflicts
Modify ports in `docker-compose.yml` if 4000, 9092, 9090, or 3000 are in use.

## License

MIT

---

"너희는 내가 너희에게 명령한 모든 것을 지켜 행하라. 그것에 더하거나 빼지 말라."
(신명기 12:32)
# potential-adventure
