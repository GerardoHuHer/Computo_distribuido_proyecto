defmodule Rover.Repo.Migrations.Evento do
  use Ecto.Migration

  def change do
    create table(:eventos_opciones, primary_key: false) do
      add :id, :integer, primary_key: true
      add :name, :string, default: "", null: false
      add :description, :string, default: "", null: false
      add :timestamp, :utc_datetime

      timestamps()
    end
  end
end
