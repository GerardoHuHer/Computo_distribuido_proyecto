defmodule Inventario.Repo.Migrations.CreateInventario do
  use Ecto.Migration

  def change do
    create table(:inventario) do
      add :id, :integer, primary_key: true
      add :name, :string, default: " "
      add :description, :string, default: ""
      add :cantidad, :integer, default: 0
      add :prioridad, :integer, default: 1
      add :timestamp, :utc_datetime

      timestamps()
    end
  end
end
