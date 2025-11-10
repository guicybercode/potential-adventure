defmodule RealtimeProcessorWeb.AggregationsController do
  use RealtimeProcessorWeb, :controller

  alias RealtimeProcessor.Pipeline.Processor

  def show(conn, %{"symbol" => symbol}) do
    aggregations = Processor.get_aggregations(symbol)
    json(conn, %{symbol: symbol, aggregations: aggregations})
  end
end

