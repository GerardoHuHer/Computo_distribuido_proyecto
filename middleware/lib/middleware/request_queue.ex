defmodule Middleware.RequestQueue do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, :queue.new()}
  end

  def handle_call({:encolar, payload}, _from, estado) do
    resultado = procesar(payload)
    {:reply, resultado, estado}
  end

  defp procesar(%{"type" => type, "action" => action, "params" => params}) do
    prefijo = "backend_#{type}"

    modulo = modulo_para(type)

    case buscar_nodo(prefijo) do
      {:ok, nodo} ->
        case :rpc.call(nodo, modulo, :handle_request, [action, params], 5000) do
          {:badrpc, reason} -> {:error, {:badrpc, reason}}
          resultado -> resultado
        end

      {:error, :no_nodes} ->
        {:error, :no_backend_disponible}
    end
  end

  # TODO: Mejorar esta función a largo plazo para encontrar el nodo con mayor disponibilidad y para usar la cola
  defp buscar_nodo(prefijo) do
    Node.list()
    |> Enum.filter(fn nodo -> String.starts_with?(Atom.to_string(nodo), prefijo) end)
    |> case do
      [] -> {:error, :no_nodes}
      [nodo | _resto] -> {:ok, nodo}
    end
  end

  defp modulo_para(tipo) do
    case tipo do
      "rover" -> RoverWeb.RpcHandler
      "clima" -> ClimaWeb.RpcHandler
      "central" -> CentralWeb.RpcHandler
      _ -> nil
    end
  end
end
