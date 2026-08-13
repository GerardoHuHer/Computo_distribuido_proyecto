
defmodule Central.Repo.Migrations.CreateRoverMejora do
  use Ecto.Migration

  def change do
    create table(:rover_mejora, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, default: ""
      add :description, :string, default: ""
      add :puntaje, :float, default: 0.0

      # Relación con la tabla 'rover' en la columna 'id_rover'
      add :id_rover, references(:rover, type: :binary_id, on_delete: :delete_all), null: false
    end

    create index(:rover_mejora, [:id_rover])
  end
end
