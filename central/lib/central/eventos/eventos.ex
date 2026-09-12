defmodule Central.Eventos.Eventos do
  use Ecto.Schema
  import Ecto.Changeset

  schema "eventos" do
    field :name, :string, default: ""
    field :description, :string, default: ""
    field :pos_x, :integer
    field :pos_y, :integer
    field :revisado, :boolean, default: false

    timestamps()
  end

  def changeset(eventos, attrs) do
    eventos
    |> cast(attrs, [:name, :description, :pos_x, :pos_y])
    |> validate_required([:name, :description, :pos_x, :pos_y])
  end
end
