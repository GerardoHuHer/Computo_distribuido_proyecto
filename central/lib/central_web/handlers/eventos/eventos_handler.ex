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

  # Función para parsear la información y devolver
  defp data(%Central.Eventos.Eventos{} = evento) do
    %{
      name: evento.name,
      description: evento.description,
      pos_x: evento.pos_x,
      pos_y: evento.pos_y
    }
  end
end
