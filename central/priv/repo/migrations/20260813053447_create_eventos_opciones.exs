
defmodule Central.Repo.Migrations.CreateEventosOpciones do
  use Ecto.Migration

  def change do
    create table(:eventos_opciones) do
      add :name, :string, default: "", null: false
      add :description, :string, default: "", null: false

      timestamps()
    end
  end
end
