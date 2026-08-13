defmodule Central.RoverMejora do
  alias Central.Repo
  alias Central.Rover.RoverMejora

  def add_mejora(attrs \\ %{}) do
    %RoverMejora{}
    |> RoverMejora.changeset(attrs)
    |> Repo.insert()
  end
end
