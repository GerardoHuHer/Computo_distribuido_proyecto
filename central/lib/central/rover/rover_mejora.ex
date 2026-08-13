defmodule Central.Rover.RoverMejora do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "rover_mejora" do
    field :name, :string, default: ""
    field :description, :string, default: ""
    field :puntaje, :float, default: 0.0

    belongs_to(:rover, Central.Rover.Rover, foreign_key: :id_rover)
  end

  def changeset(rover_mejora, attrs) do
    rover_mejora
    |> cast(attrs, [:name, :description, :puntaje, :id_rover])
    |> validate_required([:name, :id_rover])
    |> foreign_key_constraint(:id_rover)
  end
end
