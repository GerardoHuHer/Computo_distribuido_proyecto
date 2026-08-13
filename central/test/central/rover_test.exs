defmodule Central.RoverTest do
  use Central.DataCase, async: true

  alias Central.Rover
  alias Central.Rover.Rover

  describe "rover" do
    @valid_attrs %{
      pos_x: 10,
      pos_y: 20,
      timestamp: ~U[2026-08-12 23:00:00Z]
    }
    @invalid_attrs %{
      pos_x: nil,
      pos_y: nil
    }

    test "create/1 rover con datos válidos para crear un rover" do
      assert {:ok, %Rover{} = rover} = Rover.create(@valid_attrs)
      assert rover.pos_x == 10
      assert rover.pos_y == 20
    end

    test "create/1 rover con datos inválidos para crear un rover" do
      assert {:error, %Ecto.Changeset{} = changeset} = Rover.create(@invalid_attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).pos_x
      assert "can't be blank" in errors_on(changeset).pos_y
    end
  end
end
