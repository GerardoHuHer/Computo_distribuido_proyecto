defmodule Central.Rover do
  alias Central.Repo
  alias Central.Rover.Rover

  def create_rover(attrs \\ %{}) do
    %Rover{}
    |> Rover.changeset(attrs)
    |> Repo.insert()
  end
end
