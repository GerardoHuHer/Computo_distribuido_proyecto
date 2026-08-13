defmodule Central.EventosOpciones do
  alias Central.Repo
  alias Central.Eventos.EventosOpciones

  def create_eventos_opciones(attrs \\ %{}) do
    %EventosOpciones{}
    |> EventosOpciones.changeset(attrs)
    |> Repo.insert()
  end
end
