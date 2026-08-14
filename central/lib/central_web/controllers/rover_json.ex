defmodule CentralWeb.RoverJSON do
  alias Central.Rover.Rover

  def show(%{rover: rover}) do
    %{data: data(rover)}
  end

  def error(%{changeset: changeset}) do
    %{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)}
  end

  defp data(%Rover{} = rover) do
    %{
      id: rover.id,
      pos_x: rover.pos_x,
      pos_y: rover.pos_y
    }
  end

  defp translate_error({msg, opts}) do
    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
end
