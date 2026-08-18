defmodule Rover.Eventos do
  alias Rover.Eventos
  alias Rover.Repo
  alias Rover.Eventos.Eventos

  def post_all_data(list \\ []) when is_list(list) do
    {count, _} = Repo.insert_all(Rover.Eventos.Eventos, list)
    {:ok, count}
  rescue
    e in Postgrex.Error ->
      {:error, e.postgres.message}
  end

  def get_evento_random(id) do
    Repo.get(Eventos, id)
  end
end
