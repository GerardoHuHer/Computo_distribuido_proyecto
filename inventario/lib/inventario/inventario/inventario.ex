defmodule Inventario.Inventario.Inventario do
  use Ecto.Schema
  import Ecto.Changeset

  schema "inventario" do
    field :name, :string, default: " "
    field :description, :string, default: " "
    field :cantidad, :integer, default: 0
    field(:prioridad, :integer, default: 5)

    timestamps()
  end

  def changeset(inventario, attrs) do
    inventario
    |> cast(attrs, [:name, :description, :cantidad, :prioridad])
    |> validate_required([:name, :description, :cantidad, :prioridad])
    |> validate_number(:prioridad, greater_than: 1, less_than: 5)
    |> validate_number(:cantidad, greater_than: 0)
  end
end
