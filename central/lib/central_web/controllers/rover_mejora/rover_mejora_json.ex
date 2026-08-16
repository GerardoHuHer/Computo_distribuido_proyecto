defmodule CentralWeb.RoverMejoraJSON do
  # 
  alias Central.Rover.RoverMejora

  def show(%{mejora: mejora}) do
    %{data: data(mejora)}
  end

  def error(%{changeset: changeset}) do
    %{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)}
  end

  defp data(%RoverMejora{} = mejora) do
    %{
      id: mejora.id,
      name: mejora.name,
      description: mejora.description,
      puntaje: mejora.puntaje,
      id_rover: mejora.id_rover
    }
  end

  defp translate_error({msg, opts}) do
    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
end
