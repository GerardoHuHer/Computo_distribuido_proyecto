defmodule Rover.GenerateEvento do
  use GenServer
  require Logger
  alias RoverWeb.Handlers.EventosHandler

  # Función de la librería timer de erlang para setear timer a un minuto
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
          type: "central",
          action: "recibir_evento",
          params: evento
        }

        case GenServer.call(Middleware.RequestQueue, {:encolar, payload}) do
          {:error, reason} ->
            Logger.error("Error al enviar el evennto a central #{inspect(reason)}")

          _resultado ->
            :ok
        end

      {:error, reason} ->
        Logger.error("Error al obtener un evento #{inspect(reason)}")
    end

    Process.send_after(self(), :generar_evento, @timer)
    {:noreply, state}
  end
end
