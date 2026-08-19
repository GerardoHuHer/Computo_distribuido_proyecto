defmodule Rover.Vehiculo do
  alias Rover.Vehiculo
  alias Rover.Repo
  alias Rover.Vehiculo.Vehiculo

  def create_vehiculo(attrs \\ %{}) do
    %Vehiculo{}
    |> Vehiculo.changeset(attrs)
    |> Repo.insert()
  end

  # Función para traer solo un rover basado en su id nil si no existe el rover con ese id
  def get_vehiculo(id) do
    Repo.get(Vehiculo, id)
  end

  def get_all_vehiculos() do
    Repo.all(Vehiculo)
  end

  def update_vehiculo(%Vehiculo{} = vehiculo, attrs) do
    vehiculo
    |> Vehiculo.changeset(attrs)
    |> Repo.update()
  end

  def delete_vehiculo(vehiculo) do
    Repo.delete(vehiculo)
  end
end
