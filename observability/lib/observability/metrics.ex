defmodule Observability.Metrics do
  import Telemetry.Metrics
  @ms [5, 10, 25, 50, 100, 250, 500, 1_000, 2_500, 5_000, 10_000]

  def buckets, do: @ms

  def base(opts \\ []), do: phoenix() ++ vm() ++ ecto(Keyword.get(opts, :repo_prefix))

  def consumidor(app) do
    [
      counter("#{app}.cola.atender.stop.count", tags: [:action, :resultado]),
      distribution("#{app}.cola.atender.stop.duration",
        tags: [:action],
        unit: {:native, :millisecond},
        reporter_options: [buckets: @ms]
      ),
      counter("#{app}.cola.timeout.count")
    ]
  end

  defp phoenix do
    [
      distribution("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond},
        reporter_options: [buckets: @ms]
      ),
      counter("phoenix.router_dispatch.exception.count", tags: [:route])
    ]
  end

  defp vm do
    [
      last_value("vm.memory.total", unit: {:byte, :kilobyte}),
      last_value("vm.total_run_queue_lengths.total"),
      last_value("vm.total_run_queue_lengths.cpu"),
      last_value("vm.system_counts.process_count")
    ]
  end

  defp ecto(nil), do: []

  defp ecto(prefix) do
    [
      distribution("#{prefix}.query.total_time",
        unit: {:native, :millisecond},
        reporter_options: [buckets: @ms]
      )
    ]
  end
end
