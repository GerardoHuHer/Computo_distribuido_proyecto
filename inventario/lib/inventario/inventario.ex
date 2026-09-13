defmodule Inventario.Inventario do
  alias Inventario.Repo
  alias Inventario.Inventario.Inventario

  def create_item(attrs \\ %{}) do
    %Inventario{}
    |> Inventario.changeset(attrs)
    |> Repo.insert()
  end

  def read_inventory() do
    Repo.all(Inventario)
  end

  def get_one_item(id) do
    Repo.get(Inventario, id)
  end

  def update_item(%Inventario{} = inventario, attrs) do
    inventario
    |> Inventario.changeset(attrs)
    |> Repo.update()
  end

  def delete_item(%Inventario{} = inventario) do
    Repo.delete(inventario)
  end
end
