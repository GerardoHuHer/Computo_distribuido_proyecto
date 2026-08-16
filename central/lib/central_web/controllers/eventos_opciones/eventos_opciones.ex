defmodule CentralWeb.EventosOpciones do
  use CentralWeb, :controller

  alias Central.EventosOpciones

  def create(conn, %{"data" => params}) do
    case EventosOpciones.create_eventos_opciones(params) do
      {:ok, opciones} ->
        conn
        |> put_status(:created)
        |> render(:show, opciones: opciones)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, changeset: changeset)
    end
  end
end
