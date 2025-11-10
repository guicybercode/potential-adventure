defmodule Benchmark.Parsing do
  def elixir_parse_fix(message) do
    message
    |> String.split(<<0x01>>)
    |> Enum.filter(&(&1 != ""))
  end

  def elixir_crc32(data) do
    :erlang.crc32(data)
  end
end

defmodule Benchmark.Aggregation do
  def elixir_aggregate_trades(trades) do
    trades
    |> Enum.group_by(fn trade ->
      window = div(trade.timestamp, 60_000) * 60_000
      {trade.symbol, window}
    end)
    |> Enum.map(fn {{symbol, window_start}, window_trades} ->
      prices = Enum.map(window_trades, & &1.price)
      volumes = Enum.map(window_trades, & &1.quantity) |> Enum.sum()

      %{
        symbol: symbol,
        open: List.first(prices),
        high: Enum.max(prices),
        low: Enum.min(prices),
        close: List.last(prices),
        volume: volumes,
        window_start: window_start,
        window_end: window_start + 60_000
      }
    end)
  end

  def elixir_detect_anomaly(trade, history) do
    if length(history) < 10 do
      false
    else
      mean = Enum.sum(history) / length(history)
      variance = Enum.map(history, fn p -> :math.pow(p - mean, 2) end) |> Enum.sum() / length(history)
      std_dev = :math.sqrt(variance)

      if std_dev == 0.0 do
        false
      else
        z_score = abs((trade.price - mean) / std_dev)
        z_score > 3.0
      end
    end
  end
end

