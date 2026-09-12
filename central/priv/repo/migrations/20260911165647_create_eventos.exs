defmodule Central.Repo.Migrations.CreateEventos do
  use Ecto.Migration

  def change do
    create_table(:eventos) do
      add :id, :integer, primary_key: true
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
