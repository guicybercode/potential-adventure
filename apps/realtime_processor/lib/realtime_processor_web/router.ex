defmodule RealtimeProcessorWeb.Router do
  use RealtimeProcessorWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RealtimeProcessorWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RealtimeProcessorWeb do
    pipe_through :browser

    live "/", DashboardLive, :index
  end

  scope "/api", RealtimeProcessorWeb do
    pipe_through :api

    get "/metrics", MetricsController, :index
    get "/aggregations/:symbol", AggregationsController, :show
    get "/anomalies/:symbol", AnomaliesController, :show
  end
end
