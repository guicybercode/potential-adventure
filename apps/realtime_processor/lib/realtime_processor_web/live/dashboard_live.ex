defmodule RealtimeProcessorWeb.DashboardLive do
  use RealtimeProcessorWeb, :live_view

  alias RealtimeProcessor.Pipeline.Processor

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :update, 1000)
    end

    {:ok, assign(socket, aggregations: [], anomalies: [], symbol: "BTCUSD")}
  end

  @impl true
  def handle_info(:update, socket) do
    aggregations = Processor.get_aggregations(socket.assigns.symbol)
    anomalies = Processor.get_anomalies(socket.assigns.symbol)

    Process.send_after(self(), :update, 1000)

    {:noreply, assign(socket, aggregations: aggregations, anomalies: anomalies)}
  end

  @impl true
  def handle_event("change_symbol", %{"symbol" => symbol}, socket) do
    {:noreply, assign(socket, symbol: symbol)}
  end

  def handle_event("update_symbol", %{"value" => symbol}, socket) do
    {:noreply, assign(socket, symbol: symbol)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-4">
      <h1 class="text-3xl font-bold mb-4">Real-Time Trading Data Dashboard</h1>

      <div class="mb-4">
        <label class="block text-sm font-medium mb-2">Symbol:</label>
        <input
          type="text"
          value={@symbol}
          phx-change="update_symbol"
          class="border rounded px-3 py-2"
        />
      </div>

      <div class="grid grid-cols-2 gap-4">
        <div>
          <h2 class="text-xl font-semibold mb-2">Aggregations</h2>
          <div class="space-y-2">
            <%= for agg <- @aggregations do %>
              <div class="border p-2 rounded">
                <p><strong>Window:</strong> <%= agg["window_start"] %></p>
                <p>O: <%= agg["open"] %> H: <%= agg["high"] %> L: <%= agg["low"] %> C: <%= agg["close"] %></p>
                <p>Volume: <%= agg["volume"] %></p>
              </div>
            <% end %>
          </div>
        </div>

        <div>
          <h2 class="text-xl font-semibold mb-2">Anomalies</h2>
          <div class="space-y-2">
            <%= for anomaly <- @anomalies do %>
              <div class="border p-2 rounded bg-red-100">
                <p><strong>Z-Score:</strong> <%= anomaly["z_score"] %></p>
                <p><strong>Threshold:</strong> <%= anomaly["threshold"] %></p>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end

