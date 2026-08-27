defmodule RoverWeb.Handlers.VehiculoHandler do
  alias Rover.Vehiculo

  def handle_request("create_rover", params) do
    case Vehiculo.create_vehiculo(params) do
      {:ok, rover} ->
        {:ok, %{rover: rover}}

      {:error, changeset} ->
        {:error, %{changeset: changeset}}
    end
  end
end
