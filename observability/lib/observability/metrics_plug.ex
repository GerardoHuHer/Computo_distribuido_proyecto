defmodule Observability.MetricsPlug do
  @behaviour Plug
  import Plug.Conn

  @impl true
  def init(opts), do: opts

  @impl true
  def call(%Plug.Conn{request_path: "/metrics"} = conn, _opts) do
    body = TelemetryMetricsPrometheus.Core.scrape(:observability_prometheus)
    conn |> put_resp_content_type("text/plain") |> send_resp(200, body) |> halt()
  end

  def call(conn, _opts), do: conn
end