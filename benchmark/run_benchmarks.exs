Mix.install([
  {:benchee, "~> 1.2"},
  {:jason, "~> 1.2"}
])

alias Benchmark.Parsing
alias Benchmark.Aggregation

fix_message = "8=FIX.4.2" <> <<0x01>> <> "9=178" <> <<0x01>> <> "35=D" <> <<0x01>> <> "49=TEST" <> <<0x01>>
binary_data = :crypto.strong_rand_bytes(1024)

trades = for i <- 1..100 do
  %{
    symbol: "BTCUSD",
    price: 45000.0 + :rand.uniform(1000) - 500,
    quantity: :rand.uniform() * 10,
    timestamp: 1699632000000 + i * 1000,
    side: if(:rand.uniform(2) == 1, do: "buy", else: "sell")
  }
end

Benchee.run(
  %{
    "parse_fix_elixir" => fn -> Parsing.elixir_parse_fix(fix_message) end,
    "parse_fix_zig" => fn -> ZigNifs.parse_fix_message(fix_message) end,
    "crc32_elixir" => fn -> Parsing.elixir_crc32(binary_data) end,
    "crc32_zig" => fn -> ZigNifs.calculate_checksum(binary_data) end,
    "aggregate_elixir" => fn -> Aggregation.elixir_aggregate_trades(trades) end,
    "aggregate_rust" => fn ->
      aggregator = RustProcessor.create_aggregator(60_000)
      RustProcessor.aggregate_trades(aggregator, Jason.encode!(trades))
    end,
    "anomaly_elixir" => fn ->
      history = Enum.map(1..100, fn _ -> 45000.0 + :rand.uniform(1000) - 500 end)
      trade = List.first(trades)
      Aggregation.elixir_detect_anomaly(trade, history)
    end,
    "anomaly_rust" => fn ->
      detector = RustProcessor.create_detector(3.0, 1000)
      trade = List.first(trades)
      RustProcessor.detect_anomalies(detector, Jason.encode!(trade))
    end
  },
  time: 10,
  memory_time: 2,
  formatters: [
    Benchee.Formatters.Console,
    {Benchee.Formatters.Markdown, file: "benchmark/results.md"}
  ]
)

