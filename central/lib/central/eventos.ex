defmodule Central.Eventos do
  alias Central.Repo
  alias Central.Eventos.Eventos

  def post_evento_pos(attrs \\ %{}) do
    %Eventos{}
    |> Eventos.changeset(attrs)
    |> Repo.insert()
  end
end
