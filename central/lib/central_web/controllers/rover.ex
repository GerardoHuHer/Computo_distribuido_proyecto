defmodule CentralWeb.Rover do
  use CentralWeb, :controller

  alias Central.Rover

  def create(conn, %{"data" => rover_params}) do
    case Rover.create_rover(rover_params) do
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

  def get_rover(conn, %{"id" => id}) do
    case Rover.get_rover(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Rover not found"})

      rover ->
        render(conn, :show, rover: rover)
    end
  end

  def get_all_rovers_controller(conn, _params) do
    rovers = Rover.get_all_rovers()

    conn
    |> put_status(:ok)
    |> render(:index, rovers: rovers)
  end

  def move_rover_controller(conn, %{"id" => id, "data" => params}) do
    with {:ok, rover} <- fetch_rover(id),
         {:ok, updated_rover} <- Rover.update_rover(rover, params) do
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

  def delete_rover_controller(conn, %{"id" => id}) do
    with {:ok, rover} <- fetch_rover(id),
         {:ok, _} <-
           Rover.delete_rover(rover) do
      conn
      |> put_status(:ok)
      |> json(%{msg: "Rover #{id} lost connection"})
    else
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Rover #{id} not found"})

        conn

      {:error, changeset} ->
        conn
        |> put_status(:not_found)
        |> render(:error, changeset: changeset)
    end
  end

  # Funciones privadas auxiliares

  defp fetch_rover(id) do
    case Rover.get_rover(id) do
      nil -> {:error, :not_found}
      rover -> {:ok, rover}
    end
  end
end
