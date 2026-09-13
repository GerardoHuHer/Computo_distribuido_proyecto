defmodule Central.Repo.Migrations.CreateEventos do
  use Ecto.Migration

  def change do
    create table(:eventos) do
      add :name, :string, default: ""
      add :description, :string, default: ""
      add :pos_x, :integer
      add :pos_y, :integer
      add :revisado, :boolean
      add :timestamp, :utc_datetime

      timestamps()
    end
  end
end
