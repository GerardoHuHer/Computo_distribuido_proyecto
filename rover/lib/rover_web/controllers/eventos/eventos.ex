NimbleCSV.define(MyParser, separator: ",", escape: "\"")

defmodule RoverWeb.Eventos do
  use RoverWeb, :controller
  alias Rover.Eventos

  @path Path.join(File.cwd!(), "eventos.csv")
  @cantidad_registros 100

  def load_eventos_db_controller(conn, _params) do
    data = load_data_from_csv(@path)

    case Eventos.post_all_data(data) do
      {:ok, cantidad} ->
        conn
        |> put_status(:ok)
        |> json(%{"msg" => "Se han añadido los #{cantidad + 1} eventos con éxito"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, changeset: changeset)
    end
  end

  def get_evento_random_controller(conn, _params) do
    random_id = :rand.uniform(@cantidad_registros - 1)

    case Eventos.get_evento_random(random_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{msg: "Id inválido, no existe"})

      evento ->
        conn
        |> put_status(:ok)
        |> render(:show, evento: evento)
    end
  end

  defp load_data_from_csv(path) do
    now =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.truncate(:second)

    data =
      path
      |> File.stream!()
      |> MyParser.parse_stream()
      |> Stream.drop(1)
      |> Enum.map(fn [name, description] ->
        %{
          name: name,
          description: description,
          inserted_at: now,
          updated_at: now
        }
      end)

    data
  end
end
