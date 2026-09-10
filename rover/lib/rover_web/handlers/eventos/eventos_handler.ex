NimbleCSV.define(MyParser, separator: ",", escape: "\"")

defmodule RoverWeb.Handlers.EventosHandler do
  alias Rover.Vehiculo
  alias Rover.Eventos
  @path Path.join(File.cwd!(), "eventos.csv")
  @cantidad_registros 100

  def handle_request("get_evento_random", _params) do
    random_id = :rand.uniform(@cantidad_registros - 1)

    case Eventos.get_evento_random(random_id) do
      nil ->
        {:error, :not_found}

      evento ->
        # Extraer un vehiculo random para obtener las cordenadas
        vehiculo =
          case Vehiculo.get_all_vehiculos() do
            [] -> %{pos_x: 0, pos_y: 0}
            values -> values |> Map.values() |> Enum.random()
          end

        {:ok,
         %{
           name: evento.name,
           description: evento.description,
           pos_x: vehiculo.pos_x,
           pos_y: vehiculo.pos_y
         }}
    end
  end

  def handle_request("load_eventos_db", _params) do
    case Eventos.get_len_evento() do
      0 ->
        data = load_data_from_csv(@path)

        case Eventos.post_all_data(data) do
          {:ok, cantidad} ->
            {:ok, %{"msg" => "Se han añadido los #{cantidad} eventos con éxito"}}

          {:error, changeset} ->
            {:error, %{changeset: changeset}}
        end

      _ ->
        {:ok, %{"msg" => "Ya están cargados los eventos"}}
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
