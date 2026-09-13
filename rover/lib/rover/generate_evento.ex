defmodule Rover.GenerateEvento do
  use GenServer
  require Logger
  alias RoverWeb.Handlers.EventosHandler

  @timer :timer.minutes(1)

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_opts) do
    case EventosHandler.handle_request("load_eventos_db", %{}) do
      {:ok, %{"msg" => msg}} ->
        Logger.info(msg)
        Process.send_after(self(), :generar_evento, @timer)
        {:ok, %{}}

      {:error, %{changeset: changeset}} ->
        Logger.error("Error al cargar los eventos #{inspect(changeset)}")
        {:stop, :error_cargando_eventos}
    end
  end

  def handle_info(:generar_evento, state) do
    case EventosHandler.handle_request("get_evento_random", %{}) do
      {:ok, evento} ->
        payload = %{
          "type" => "central",
          "action" => "recibir_evento",
          "params" => evento
        }

        case enviar_a_middleware(payload) do
          {:error, reason} ->
            Logger.error("Error al enviar el evento a central #{inspect(reason)}")

          _resultado ->
            :ok
        end

      {:error, reason} ->
        Logger.error("Error al obtener un evento #{inspect(reason)}")
    end

    Process.send_after(self(), :generar_evento, @timer)
    {:noreply, state}
  end

  defp enviar_a_middleware(payload) do
    case buscar_middleware() do
      nil ->
        {:error, :middleware_no_disponible}

      nodo ->
        case :rpc.call(
               nodo,
               GenServer,
               :call,
               [Middleware.RequestQueue, {:encolar, payload}, 10_000],
               15_000
             ) do
          {:badrpc, reason} -> {:error, {:badrpc, reason}}
          resultado -> resultado
        end
    end
  end

  defp buscar_middleware do
    Node.list()
    |> Enum.find(fn nodo -> String.starts_with?(Atom.to_string(nodo), "middleware") end)
  end
end
