defmodule Observability.Trace do
  require OpenTelemetry.Tracer, as: Tracer

  def setup(opts \\ []) do
    OpentelemetryBandit.setup()
    OpentelemetryPhoenix.setup(adapter: :bandit)

    if repo = opts[:repo], do: OpentelemetryEcto.setup(repo)

    :ok
  end

  def inject(payload) do
    carrier = :otel_propagator_text_map.inject([]) |> Map.new()

    payload
    |> Map.put("_trace", carrier)
    |> Map.put("_enq_ts", System.system_time(:millisecond))
  end

  def with_span(name, payload, attributes, fun) do
    payload
    |> Map.get("_trace", %{})
    |> Map.to_list()
    |> :otel_propagator_text_map.extract()

    Tracer.with_span name, %{kind: :consumer, attributes: attributes} do
      if ts = payload["_enq_ts"] do
        Tracer.set_attribute(:queue_wait_ms, System.system_time(:millisecond) - ts)
      end

      fun.()
    end
  end
end
