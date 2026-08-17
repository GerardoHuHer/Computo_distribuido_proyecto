defmodule RoverWeb.Eventos do
  use RoverWeb, :controller
  alias Rover.Eventos

  @path ""
  @cantidad_registros 10

  def load_eventos_db_controller(conn, _params) do
    data = load_data_from_csv(@path)

    case Eventos.post_all_data(data) do
      {:ok, _response} ->
        conn
        |> put_status(:ok)
        |> json_response(%{"msg" => "Se han añadido los eventos con éxito"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, changeset: changeset)
    end
  end

  def get_evento_random_controller(conn, _params) do
    random_id = :rand.uniform(@cantidad_registros - 1)

    case get_evento_random(random_id) do
      {:ok, evento} ->
        conn
        |> put_status(:ok)
        |> render(:show, evento: evento)

      {:error, error} ->
        conn
        |> put_status(:not_found)
        |> json(conn, %{msg: "Id inválido, no existe"})
    end
  end

  defp load_data_from_csv(path) do
    NimbleCSV.define(MyParser, separator: ",", escape: "\"")

    data =
      path
      |> File.stream!()
      |> MyParser.parse_stream()
      |> Enum.to_list()

    data
  end
end
