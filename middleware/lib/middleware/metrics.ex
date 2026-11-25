defmodule Middleware.Metrics do
  import Telemetry.Metrics

  def custom do
    [
      last_value("middleware.cola.estado.pendientes", tags: [:tipo]),
      counter("middleware.cola.rechazo.count", tags: [:tipo]),
      distribution("middleware.gateway.stop.duration",
        tags: [:type, :action, :status],
        unit: {:native, :millisecond},
        reporter_options: [buckets: Observability.Metrics.buckets()]
      )
    ]
  end
end
