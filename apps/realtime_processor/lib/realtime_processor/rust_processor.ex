defmodule RustProcessor do
  use Rustler, 
    otp_app: :realtime_processor, 
    crate: :rust_processor,
    path: Path.expand("../../../../native/rust_processor", __DIR__)

  def create_aggregator(_window_size_ms), do: :erlang.nif_error(:nif_not_loaded)
  def aggregate_trades(_resource, _trades_json), do: :erlang.nif_error(:nif_not_loaded)
  def create_detector(_threshold, _max_history), do: :erlang.nif_error(:nif_not_loaded)
  def detect_anomalies(_resource, _trade_json), do: :erlang.nif_error(:nif_not_loaded)
end

