defmodule Central.Repo.Migrations.CreateEventosPasados do
  use Ecto.Migration

  def change do
    create table(:eventos_pasados, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :rover_position_x, :integer, default: 0, null: false
      add :rover_position_y, :integer, default: 0, null: false
      add :timestamp, :utc_datetime, null: false

      # Llave foránea hacia 'rover' (binary_id)
      add :id_rover, references(:rover, type: :binary_id, on_delete: :delete_all), null: false

      # Llave foránea hacia 'eventos_opciones' (integer por defecto en Ecto)
      add :id_evento, references(:eventos_opciones, type: :integer, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:eventos_pasados, [:id_rover])
    create index(:eventos_pasados, [:id_evento])
  end
end
