defmodule RealtimeProcessorWeb.MetricsController do
  use RealtimeProcessorWeb, :controller

  def index(conn, _params) do
    metrics = TelemetryMetricsPrometheus.Core.scrape()
    text(conn, metrics)
  end
end

