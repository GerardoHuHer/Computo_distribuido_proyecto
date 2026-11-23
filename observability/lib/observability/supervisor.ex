defmodule Observability.Supervisor do
  use Supervisor
  def start_link(opts), do: Supervisor.start_link(__MODULE__, opts, name: __MODULE__)

  @impl true
  def init(opts) do
    metrics = Observability.Metrics.base(repo_prefix: opts[:repo_prefix]) ++ Keyword.get(opts, :metrics, [])
    Supervisor.init(
      [{TelemetryMetricsPrometheus.Core, metrics: metrics, name: :observability_prometheus}],
      strategy: :one_for_one)
  end
end