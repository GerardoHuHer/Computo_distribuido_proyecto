defmodule RoverWeb.Handlers.VehiculoHandler do
  alias Rover.Vehiculo

  def handle_request("create_rover", params) do
    case Vehiculo.create_vehiculo(params) do
      {:ok, rover} ->
        {:ok,
         %{
           id: rover.id,
           pos_x: rover.pos_x,
           pos_y: rover.pos_y
         }}

      {:error, changeset} ->
        {:error, %{changeset: changeset}}
    end
  end
end
