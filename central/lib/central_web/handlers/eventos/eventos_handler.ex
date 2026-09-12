defmodule CentralWeb.Handlers.EventosHandler do
  alias Central.Eventos

  # Función para almacenar los eventos que va a generar rover
  def handle_request("recibir_evento", params) do
    case Eventos.post_evento_pos(params) do
      {:ok, evento} ->
        {:ok, data(evento)}

      {:error, changeset} ->
        {:error, %{changeset: changeset}}
    end
  end

  def handle_request("read_all_events", _params) do
    eventos = Eventos.read_all_eventos()
    {:ok, for(evento <- eventos, do: data(evento))}
  end

  def handle_request("update_event", params) do
    with {:ok, evento} <- fetch_evento(params["id"]),
         {:ok, updated_evento} <- Eventos.update_revisado(evento, params) do
      {:ok, data(updated_evento)}
    else
      {:error, :not_found} ->
        {:error, %{msg: "Evento not found"}}

      {:error, changeset} ->
        {:error, %{msg: changeset}}
    end
  end

  def handle_request("delete_event", params) do
    with {:ok, rover} <- fetch_evento(params["id"]),
         {:ok, _} <-
           Eventos.delete_evetos(rover) do
      {:ok, %{msg: "Evento #{rover} was deleted"}}
    else
      {:error, :not_found} ->
        {:error, %{msg: "Evento not found"}}
    end
  end

  # Función para parsear la información y devolver
  defp data(%Central.Eventos.Eventos{} = evento) do
    %{
      name: evento.name,
      description: evento.description,
      pos_x: evento.pos_x,
      pos_y: evento.pos_y
    }
  end

  defp fetch_evento(id) do
    case Eventos.get_evento(id) do
      nil -> {:error, :not_found}
      rover -> {:ok, rover}
    end
  end
end
