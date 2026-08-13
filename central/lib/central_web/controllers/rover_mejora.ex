defmodule CentralWeb.RoverMejora do
  use CentralWeb, :controller

  alias Central.RoverMejora

  def add_mejora(conn, %{"data" => mejora_paras}) do
    case RoverMejora.add_mejora(mejora_paras) do
      {:ok, mejora} ->
        conn
        |> put_status(:created)
        |> render(:show, mejora: mejora)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, changeset: changeset)
    end
  end
end
