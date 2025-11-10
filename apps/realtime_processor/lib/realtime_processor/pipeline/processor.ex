defmodule RealtimeProcessor.Pipeline.Processor do
  use GenServer
  require Logger

  alias RealtimeProcessor.Metrics

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    aggregator_1min = RustProcessor.create_aggregator(60_000)
    aggregator_5min = RustProcessor.create_aggregator(300_000)
    aggregator_1hour = RustProcessor.create_aggregator(3_600_000)
    detector = RustProcessor.create_detector(3.0, 1000)

    state = %{
      aggregators: %{
        "1min" => aggregator_1min,
        "5min" => aggregator_5min,
        "1hour" => aggregator_1hour
      },
      detector: detector,
      aggregations: :ets.new(:aggregations, [:set, :public]),
      anomalies: :ets.new(:anomalies, [:set, :public])
    }

    {:ok, state}
  end

  def process_batch(trades) do
    GenServer.cast(__MODULE__, {:process_batch, trades})
  end

  def get_aggregations(symbol) do
    GenServer.call(__MODULE__, {:get_aggregations, symbol})
  end

  def get_anomalies(symbol) do
    GenServer.call(__MODULE__, {:get_anomalies, symbol})
  end

  def handle_cast({:process_batch, trades}, state) do
    start_time = System.monotonic_time(:microsecond)

    Enum.each(trades, fn trade ->
      process_trade(trade, state)
    end)

    duration = System.monotonic_time(:microsecond) - start_time
    Metrics.record_batch_processing(duration, length(trades))

    {:noreply, state}
  end

  def handle_call({:get_aggregations, symbol}, _from, state) do
    results =
      :ets.match_object(state.aggregations, {:_, symbol, :_})
      |> Enum.map(fn {_, _, data} -> data end)

    {:reply, results, state}
  end

  def handle_call({:get_anomalies, symbol}, _from, state) do
    results =
      :ets.match_object(state.anomalies, {:_, symbol, :_})
      |> Enum.map(fn {_, _, data} -> data end)

    {:reply, results, state}
  end

  defp process_trade(trade, state) do
    trade_map = if is_map(trade) and :erlang.is_map_key(:__struct__, trade) == false do
      trade
    else
      Map.new(trade, fn {k, v} -> {to_string(k), v} end)
    end

    trade_json = Jason.encode!(trade_map)

    Enum.each(state.aggregators, fn {window, aggregator} ->
      result_json = RustProcessor.aggregate_trades(aggregator, Jason.encode!([trade_map]))

      case Jason.decode(result_json) do
        {:ok, ohlc_list} ->
          Enum.each(ohlc_list, fn ohlc ->
            key = {ohlc["symbol"], window, ohlc["window_start"]}
            :ets.insert(state.aggregations, {key, ohlc["symbol"], ohlc})
          end)

        {:error, _} ->
          :ok
      end
    end)

    anomaly_result_json = RustProcessor.detect_anomalies(state.detector, trade_json)

    case Jason.decode(anomaly_result_json) do
      {:ok, %{"is_anomaly" => true} = result} ->
        symbol = Map.get(trade_map, "symbol") || Map.get(trade_map, :symbol)
        timestamp = Map.get(trade_map, "timestamp") || Map.get(trade_map, :timestamp)
        key = {symbol, timestamp}
        :ets.insert(state.anomalies, {key, symbol, result})
        Metrics.record_anomaly(symbol)

      {:ok, _} ->
        :ok

      {:error, _} ->
        :ok
    end
  end
end

