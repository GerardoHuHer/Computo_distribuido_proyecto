defmodule Central.Eventos.EventosOpciones do
  use Ecto.Schema
  import Ecto.Changeset

  schema "eventos_opciones" do
    field :name, :string, default: ""
    field :description, :string, default: ""

    has_many :eventos_pasados, Central.Eventos.EventosPasados, foreign_key: :id_evento

    timestamps()
  end

  def changeset(eventos_opciones, attrs) do
    eventos_opciones
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
