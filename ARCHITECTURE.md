# Architecture Documentation

## System Design

### Data Flow

1. **Ingestion**: Kafka topics (`trades`, `orders`) receive financial trade messages
2. **Consumption**: Broadway pipeline consumes messages with configurable concurrency
3. **Parsing**: Zig NIF parses binary FIX protocol messages and validates checksums
4. **Normalization**: Elixir deserializes JSON and normalizes data structures
5. **Aggregation**: Rust NIF aggregates trades into sliding windows (1min, 5min, 1hour)
6. **Anomaly Detection**: Rust NIF detects price anomalies using statistical Z-score
7. **Storage**: Results stored in ETS tables for fast in-memory access
8. **Exposure**: Phoenix endpoints serve aggregated data and anomalies
9. **Observability**: Telemetry events flow to Prometheus and OpenTelemetry

### Component Responsibilities

#### Elixir Layer
- **Broadway Pipeline**: Handles Kafka message consumption with backpressure
- **Processor GenServer**: Orchestrates NIF calls and manages state
- **ETS Tables**: Fast in-memory storage for aggregations and anomalies
- **Phoenix API**: REST endpoints for querying results
- **LiveView**: Real-time dashboard for monitoring

#### Rust Layer
- **SlidingWindowAggregator**: Maintains time-based windows for OHLC calculation
- **ZScoreDetector**: Statistical anomaly detection with configurable threshold
- **Resource Management**: Rustler resources for stateful NIFs

#### Zig Layer
- **FIX Parser**: Efficient binary parsing with zero-copy where possible
- **CRC32**: Optimized checksum calculation for message validation

### Fault Tolerance

- **Supervision Trees**: All critical processes supervised with restart strategies
- **Broadway**: Automatic message retry and dead letter queue support
- **NIF Safety**: Rust and Zig NIFs designed to not crash the BEAM VM
- **Health Checks**: Docker health checks for all services

### Scalability

- **Horizontal Scaling**: Stateless design allows multiple instances
- **Kafka Partitioning**: Broadway supports Kafka partition distribution
- **Concurrency**: Configurable processor and batcher concurrency
- **Resource Limits**: ETS table cleanup prevents memory leaks

### Performance Optimizations

- **NIFs**: Native code for hot paths (parsing, aggregation)
- **Batching**: Broadway batches messages to reduce overhead
- **ETS**: In-memory storage for fast lookups
- **Resource Pooling**: Reused Rust/Zig resources across calls

## Technology Choices

### Why Elixir?
- Excellent concurrency model for I/O-bound operations
- Fault tolerance built into the language
- Broadway provides excellent Kafka integration
- Phoenix LiveView enables real-time UIs

### Why Rust?
- Memory safety with performance
- Excellent for complex data transformations
- Rustler provides safe NIF integration
- Strong ecosystem for financial data processing

### Why Zig?
- Minimal runtime overhead
- Predictable performance characteristics
- Excellent for binary parsing
- Zigler enables safe NIF creation

## Monitoring and Observability

### Metrics Collected
- Message throughput
- Processing latency (p50, p95, p99)
- Anomaly detection rate
- Error rates
- VM metrics (memory, CPU)

### Traces
- OpenTelemetry spans for request flow
- Distributed tracing across components

### Logs
- Structured JSON logging
- Contextual metadata (symbol, topic, request_id)

## Security Considerations

- Input validation on all API endpoints
- NIFs validate input before processing
- No SQL injection (using ETS, not database)
- Rate limiting recommended for production

## Future Enhancements

- Database persistence for historical data
- WebSocket streaming for real-time updates
- Machine learning anomaly detection
- Multi-region deployment support
- Advanced windowing strategies

