defmodule RealtimeProcessor.Metrics do
  require Logger

  def record_batch_processing(duration, count) do
    :telemetry.execute(
      [:realtime_processor, :batch, :processed],
      %{duration: duration, count: count},
      %{}
    )
  end

  def record_anomaly(symbol) do
    :telemetry.execute(
      [:realtime_processor, :anomaly, :detected],
      %{count: 1},
      %{symbol: symbol}
    )
  end

  def record_message_processing(duration) do
    :telemetry.execute(
      [:realtime_processor, :message, :processed],
      %{duration: duration},
      %{}
    )
  end
end

