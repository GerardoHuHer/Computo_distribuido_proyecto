defmodule RoverWeb.Vehiculo do
  use RoverWeb, :controller

  alias Rover.Vehiculo

  def create(conn, %{"data" => rover_params}) do
    case Vehiculo.create_vehiculo(rover_params) do
      {:ok, rover} ->
        conn
        |> put_status(:created)
        |> render(:show, rover: rover)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, changeset: changeset)
    end
  end

  def get_vehiculo(conn, %{"id" => id}) do
    case Vehiculo.get_vehiculo(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Rover not found"})

      rover ->
        render(conn, :show, rover: rover)
    end
  end

  def get_all_vehiculos_controller(conn, _params) do
    rovers = Vehiculo.get_all_vehiculos()

    conn
    |> put_status(:ok)
    |> render(:index, rovers: rovers)
  end

  def move_vehiculo_controller(conn, %{"id" => id, "data" => params}) do
    with {:ok, rover} <- fetch_rover(id),
         {:ok, updated_rover} <- Vehiculo.update_vehiculo(rover, params) do
      conn
      |> put_status(:ok)
      |> render(:show, rover: updated_rover)
    else
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Rover not found"})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, changeset: changeset)
    end
  end

  def delete_vehiculo_controller(conn, %{"id" => id}) do
    with {:ok, rover} <- fetch_rover(id),
         {:ok, _} <-
           Vehiculo.delete_vehiculo(rover) do
      conn
      |> put_status(:ok)
      |> json(%{msg: "Rover #{id} lost connection"})
    else
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Rover #{id} not found"})
    end
  end

  # Funciones privadas auxiliares

  defp fetch_rover(id) do
    case Vehiculo.get_vehiculo(id) do
      nil -> {:error, :not_found}
      rover -> {:ok, rover}
    end
  end
end
