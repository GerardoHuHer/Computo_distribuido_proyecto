defmodule Central.Eventos.EventosPasados do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "eventos_pasados" do
    field :rover_position_x, :integer, default: 0
    field :rover_position_y, :integer, default: 0
    field :timestamp, :utc_datetime

    belongs_to :rover, Central.Rover.Rover, foreign_key: :id_rover
    belongs_to :evento, Central.Eventos.EventosOpciones, foreign_key: :id_evento, type: :integer

    timestamps()
  end

  # Corregido typo: changeset (con 'n')
  def changeset(eventos_pasados, attrs) do
    eventos_pasados
    |> cast(attrs, [
      :rover_position_x,
      :rover_position_y,
      # Corregido a singular
      :timestamp,
      :id_rover,
      :id_evento
    ])
    |> validate_required([
      :rover_position_x,
      :rover_position_y,
      :timestamp,
      :id_rover,
      :id_evento
    ])
    |> foreign_key_constraint(:id_rover)
    |> foreign_key_constraint(:id_evento)
  end
end
