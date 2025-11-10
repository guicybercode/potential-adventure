defmodule RealtimeProcessorWeb.PageController do
  use RealtimeProcessorWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
