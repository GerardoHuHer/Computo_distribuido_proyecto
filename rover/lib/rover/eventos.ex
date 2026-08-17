defmodule Rover.Eventos do
  alias Rover.Eventos
  alias Rover.Repo
  alias Rover.Eventos.Eventos

  # Alternativa 
  # Repo.insert_all
  def post_all_data(list \\ []) do
    Repo.transaction(fn ->
      Enum.each(list, fn i ->
        i
        |> Eventos.changeset()
        |> Repo.insert!()
      end)
    end)
  rescue
    e in Ecto.InvalidChangesetError ->
      {:error, e.changeset}
  end

  def get_evento_random(id) do
    Repo.get(Eventos, id)
  end
end
