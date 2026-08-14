defmodule Central.Rover do
  alias Central.Rover
  alias Central.Repo
  alias Central.Rover.Rover

  def create_rover(attrs \\ %{}) do
    %Rover{}
    |> Rover.changeset(attrs)
    |> Repo.insert()
  end

  # Función para traer solo un rover basado en su id nil si no existe el rover con ese id
  def get_rover(id) do
    Repo.get(Rover, id)
  end

  def update_rover(%Rover{} = rover, attrs) do
    rover
    |> Rover.changeset(attrs)
    |> Repo.update()
  end

  def delete_rover(id) do
    Repo.delete(id)
  end
end
