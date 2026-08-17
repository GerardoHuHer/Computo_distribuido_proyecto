defmodule Rover.Eventos.EventosOpciones do
  use Ecto.Schema
  import Ecto.Changeset

  schema "eventos_opciones" do
    field :name, :string, default: ""
    field :description, :string, default: ""

    timestamps()
  end

  def changeset(eventos_opciones, attrs) do
    eventos_opciones
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
