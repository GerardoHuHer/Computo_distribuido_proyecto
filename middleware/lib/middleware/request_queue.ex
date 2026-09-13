defmodule Middleware.RequestQueue do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_opts) do
    # Iniciamos el proceso con una cola nueva, un mapa vació y las tareas que se tienen que realizar
    # en la cola almacenamos la peticiones pendientes
    # Ocupados será un mapa con los nodos que están ocupados
    # Mapa que almacena la tarea con la referencia de la tarea, de donde viene y en que nodo está y como liberarlo
    {:ok, %{cola: :queue.new(), ocupados: MapSet.new(), tareas: %{}}}
  end

  def handle_call({:encolar, payload}, from, estado) do
    # Creamos un elemento nuevo de la cola con el payload, de donde viene y el estado de la cola
    nueva_cola = :queue.in({payload, from}, estado.cola)
    # Metemos al estado la nueva cola y aplicamos función despachar
    nuevo_estado = %{estado | cola: nueva_cola}
    {:noreply, despachar(nuevo_estado)}
  end

  def handle_info({ref, resultado}, estado) when is_reference(ref) do
    # Dejamos de "supervisar" el proceso
    Process.demonitor(ref, [:flush])

    # Extraemos el valor con la llave ref en estado.tareas
    case Map.pop(estado.tareas, ref) do
      {{from, nodo}, tareas_restantes} ->
        GenServer.reply(from, resultado)

        nuevo_estado = %{
          estado
          | ocupados: MapSet.delete(estado.ocupados, nodo),
            tareas: tareas_restantes
        }

        {:noreply, despachar(nuevo_estado)}

      {nil, _} ->
        {:noreply, estado}
    end
  end

  def handle_info({:DOWN, _ref, :process, _pid, _reason}, estado) do
    {:noreply, estado}
  end

  defp despachar(estado) do
    case :queue.out(estado.cola) do
      {:empty, _} ->
        estado

      {{:value, {payload, from}}, resto_cola} ->
        %{"type" => type} = payload
        prefijo = "backend_#{type}"

        case modulo_para(type) do
          nil ->
            GenServer.reply(from, {:error, {:tipo_no_soportado, type}})
            %{estado | cola: resto_cola} |> despachar()

          modulo ->
            case buscar_nodo_libre(prefijo, estado.ocupados) do
              {:ok, nodo} ->
                ref = lanzar_tarea(nodo, modulo, payload)
                tareas = Map.put(estado.tareas, ref, {from, nodo})

                estado
                |> Map.put(:tareas, tareas)
                |> Map.put(:cola, resto_cola)
                |> Map.update!(:ocupados, &MapSet.put(&1, nodo))
                |> despachar()

              {:error, :no_nodes} ->
                estado
            end
        end
    end
  end

  defp lanzar_tarea(nodo, modulo, %{"action" => action, "params" => params}) do
    task =
      Task.Supervisor.async_nolink(Middleware.TaskSupervisor, fn ->
        case :rpc.call(nodo, modulo, :handle_request, [action, params], 5000) do
          {:badrpc, reason} -> {:error, {:badrpc, reason}}
          resultado -> resultado
        end
      end)

    task.ref
  end

  defp buscar_nodo_libre(prefijo, ocupados) do
    Node.list()
    |> Enum.filter(fn nodo -> String.starts_with?(Atom.to_string(nodo), prefijo) end)
    |> Enum.reject(fn nodo -> MapSet.member?(ocupados, nodo) end)
    |> case do
      [] -> {:error, :no_nodes}
      [nodo | _resto] -> {:ok, nodo}
    end
  end

  defp modulo_para(tipo) do
    case tipo do
      "rover" -> RoverWeb.RpcHandler
      "inventario" -> InventarioWeb.RpcHandler
      "central" -> CentralWeb.RpcHandler
      _ -> nil
    end
  end
end
