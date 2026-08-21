defmodule Rover.Vehiculo.Vehiculo do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "vehiculo" do
    field :pos_x, :integer, default: 0
    field :pos_y, :integer, default: 0
    field :timestamp, :utc_datetime

    # Conexión con mejoras.
    has_many :mejora, Rover.Vehiculo.Mejora, foreign_key: :id_rover
    timestamps()
  end

  def changeset(rover, attrs) do
    rover
    |> cast(attrs, [:pos_x, :pos_y, :timestamp])
    |> validate_required([:pos_x, :pos_y])
  end

  def update_position_changeset(rover, attrs) do
    rover
    |> cast(attrs, [:pos_x, :pos_y, :timestamp])
    |> validate_required([:pos_x, :pos_y])
    |> put_change(:timestamp, DateTime.truncate(DateTime.utc_now(), :second))
  end
end
