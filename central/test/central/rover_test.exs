defmodule Central.RoverTest do
  use Central.DataCase, async: true

  alias Central.Rover.Rover
  import Central.Rover

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
    @update_attrs %{
      pos_x: 5,
      pos_y: 5
    }


    test "create_rover/1 rover con datos válidos para crear un rover" do
      assert {:ok, %Rover{} = rover} = create_rover(@valid_attrs)
      assert rover.pos_x == 10
      assert rover.pos_y == 20
    end

    test "create_rover/1 rover con datos inválidos para crear un rover" do
      assert {:error, %Ecto.Changeset{} = changeset} = create_rover(@invalid_attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).pos_x
      assert "can't be blank" in errors_on(changeset).pos_y
    end

    test "get_rover/1 leer rover de la base de datos" do
      {:ok, created_rover} = create_rover(@valid_attrs)
      rover = get_rover(created_rover.id)
      assert created_rover.id == rover.id
      assert @valid_attrs.pos_x == rover.pos_x
      assert @valid_attrs.pos_y == rover.pos_y
    end

    test "get_rover/1 leer rover que no existe" do
      assert get_rover(Ecto.UUID.generate()) == nil
    end

    test "get_all_rovers/0 leer todos los rovers" do
      {:ok, rover} = create_rover(@valid_attrs)
      assert get_all_rovers() == [rover]
    end

    test "update_rover/2 actualizar el rover" do
      {:ok, rover} = create_rover(@valid_attrs)
      assert {:ok, updated_rover } = update_rover(rover, @update_attrs) 
      assert @update_attrs.pos_x == updated_rover.pos_x
      assert @update_attrs.pos_y == updated_rover.pos_y
    end

    test "update_rover/2 actualizar el rover cuando no existe" do
      {:ok, rover} = create_rover(@valid_attrs)
      assert {:error, %Ecto.Changeset{}} = update_rover(rover, @invalid_attrs) 
      assert rover == get_rover(rover.id)
    end

    test "delete_rover/1" do
      {:ok, rover} = create_rover(@valid_attrs)
      assert {:ok, %Rover{} = rover} = delete_rover(rover)
      assert get_rover(rover.id) == nil
    end

  end
end
