defmodule Rover.Cola.Consumidor do
  use GenStage

  alias RoverWeb.RpcHandler

  @productor :cola_rover
  @max_demand 10
  @min_demand 5
  @retry 1_000

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    send(self(), :suscribir)
    {:consumer, %{}}
  end

  @impl true
  def handle_info(:suscribir, estado) do
    case buscar_middleware() do
      nil ->
        Process.send_after(self(), :suscribir, @retry)

      nodo ->
        GenStage.async_subscribe(self(),
          to: {@productor, nodo},
          cancel: :temporary,
          max_demand: @max_demand,
          min_demand: @min_demand
        )
    end

    {:noreply, [], estado}
  end

  @impl true
  def handle_cancel(_razon, _from, estado) do
    Process.send_after(self(), :suscribir, @retry)
    {:noreply, [], estado}
  end

  @impl true
  def handle_events(eventos, _from, estado) do
    eventos
    |> Task.async_stream(&atender/1,
      max_concurrency: @max_demand,
      ordered: false,
      timeout: 10_000,
      on_timeout: :kill_task
    )
    |> Stream.run()

    {:noreply, [], estado}
  end

  def atender({%{"action" => action} = payload, from}) do
    resultado =
      try do
        RpcHandler.handle_request(action, Map.get(payload, "params", %{}))
      rescue
        e -> {:error, Exception.message(e)}
      end

    GenStage.reply(from, resultado)
  end

  defp buscar_middleware do
    Enum.find(Node.list(), &String.starts_with?(Atom.to_string(&1), "middleware"))
  end
end
