defmodule RoverWeb.Handlers.VehiculoHandler do
  alias Rover.Vehiculo

  def handle_request("create_rover", params) do
    case Vehiculo.create_vehiculo(params) do
      {:ok, rover} ->
        {:ok, data(rover)}

      {:error, changeset} ->
        {:error, %{changeset: changeset}}
    end
  end

  def handle_request("get_all_vehiculos", _params) do
    vehiculos = Vehiculo.get_all_vehiculos()
    {:ok, for(vehiculo <- vehiculos, do: data(vehiculo))}
  end

  def handle_request("get_vehiculo", params) do
    case Vehiculo.get_vehiculo(params["id"]) do
      nil ->
        {:error, %{error: "Rover not found"}}

      rover ->
        {:ok, data(rover)}
    end
  end

  defp data(%Rover.Vehiculo.Vehiculo{} = vehiculo) do
    %{
      id: vehiculo.id,
      pos_x: vehiculo.pos_x,
      pos_y: vehiculo.pos_y
    }
  end
end
