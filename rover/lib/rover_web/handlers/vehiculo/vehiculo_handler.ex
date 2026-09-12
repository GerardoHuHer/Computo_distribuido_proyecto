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

  def handle_request("move_vehiculo", params) do
    with {:ok, rover} <- fetch_rover(params["id"]),
         {:ok, updated_rover} <- Vehiculo.update_vehiculo(rover, params) do
      {:ok, data(updated_rover)}
    else
      {:error, :not_found} ->
        {:error, %{msg: "Rover not found"}}

      {:error, changeset} ->
        {:error, %{msg: changeset}}
    end
  end

  def handle_request("delete_vehiculo", params) do
    with {:ok, rover} <- fetch_rover(params["id"]),
         {:ok, _} <-
           Vehiculo.delete_vehiculo(rover) do
      {:ok, %{msg: "Rover #{rover} was deleted"}}
    else
      {:error, :not_found} ->
        {:error, %{msg: "Rover not found"}}
    end
  end

  defp data(%Rover.Vehiculo.Vehiculo{} = vehiculo) do
    %{
      id: vehiculo.id,
      pos_x: vehiculo.pos_x,
      pos_y: vehiculo.pos_y
    }
  end

  defp fetch_rover(id) do
    case Vehiculo.get_vehiculo(id) do
      nil -> {:error, :not_found}
      rover -> {:ok, rover}
    end
  end
end
