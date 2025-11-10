defmodule RealtimeProcessorWeb.AnomaliesController do
  use RealtimeProcessorWeb, :controller

  alias RealtimeProcessor.Pipeline.Processor

  def show(conn, %{"symbol" => symbol}) do
    anomalies = Processor.get_anomalies(symbol)
    json(conn, %{symbol: symbol, anomalies: anomalies})
  end
end

