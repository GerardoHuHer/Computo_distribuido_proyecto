defmodule Rover.Eventos do
  alias Rover.Repo
  alias Rover.Eventos.EventosOpciones

  def post_all_data(list \\ []) when is_list(list) do
    {count, _} = Repo.insert_all(EventosOpciones, list)
    {:ok, count}
  rescue
    e in Postgrex.Error ->
      {:error, e.postgres.message}
  end

  def get_evento_random(id) do
    Repo.get(EventosOpciones, id)
  end
end
