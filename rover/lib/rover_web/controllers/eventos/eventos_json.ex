defmodule RoverWeb.Eventos.EventosJSON do
  alias Rover.Eventos.EventosOpciones

  def show(%{evento: evento}), do: %{data: data(evento)}

  def error(%{changeset: changeset}) do
    %{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)}
  end

  defp data(%EventosOpciones{} = evento) do
    %{
      id: evento.id,
      name: evento.name,
      description: evento.description
    }
  end

  defp translate_error({msg, opts}) do
    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
end
