defmodule Rover.Repo.Migrations.Evento do
  use Ecto.Migration

  def change do
    create table(:eventos_opciones) do
      add :name, :string, default: "", null: false
      add :description, :string, default: "", null: false
      add :timestamp, :utc_datetime

      timestamps()
    end
  end
end
