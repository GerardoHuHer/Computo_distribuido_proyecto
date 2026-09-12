defmodule Central.Eventos do
  alias Central.Repo
  alias Central.Eventos.Eventos

  # Create a event 
  def post_evento_pos(attrs \\ %{}) do
    %Eventos{}
    |> Eventos.changeset(attrs)
    |> Repo.insert()
  end

  # Read all events
  def read_all_eventos() do
    Repo.all(Eventos)
  end

  def get_evento(id) do
    Repo.get(Eventos, id)
  end

  # Change the revisado field.
  def update_revisado(%Eventos{} = evento, attrs) do
    evento
    |> Eventos.changeset(attrs)
    |> Repo.update()
  end

  # Delete an event
  def delete_evetos(evento) do
    Repo.delete(evento)
  end
end
