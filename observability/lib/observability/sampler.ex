defmodule Observability.Sampler do
  @behaviour :otel_sampler

  @impl true
  def setup(opts), do: opts

  @impl true
  def description(_config), do: "IgnorarMetricsSampler"

  @impl true
  def should_sample(ctx, _trace_id, _links, _name, _kind, attributes, _config) do
    tracestate = ctx |> :otel_tracer.current_span_ctx() |> :otel_span.tracestate()

    case attributes do
      %{"url.path": "/metrics"} -> {:drop, [], tracestate}
      _ -> {:record_and_sample, [], tracestate}
    end
  end
end
