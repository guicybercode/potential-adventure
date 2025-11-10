defmodule RealtimeProcessor.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RealtimeProcessorWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:realtime_processor, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: RealtimeProcessor.PubSub},
      RealtimeProcessor.Pipeline.Processor,
      RealtimeProcessor.Pipeline.Broadway,
      RealtimeProcessorWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: RealtimeProcessor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RealtimeProcessorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
