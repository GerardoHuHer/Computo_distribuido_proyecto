defmodule Rover.Repo.Migrations.Vehiculo do
  use Ecto.Migration

  def change do
    create table(:vehiculo, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :pos_x, :integer, default: 0, null: false
      add :pos_y, :integer, default: 0, null: false
      add :timestamp, :utc_datetime

      timestamps()
    end
  end
end
