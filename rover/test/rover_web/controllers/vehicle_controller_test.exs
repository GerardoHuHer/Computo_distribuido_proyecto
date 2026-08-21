defmodule RoverWeb.VehiculoControllerTest do
  use RoverWeb.ConnCase, async: true

  @valid_attrs %{
    "pos_x" => 10,
    "pos_y" => 20,
    "timestamp" => "2026-08-12T23:00:00Z"
  }

  @invalid_attrs %{
    "pos_x" => nil,
    "pos_y" => nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "POST /api/create_vehiculo (create)" do
    test "test con HTTP 201, lo crea cuando los datos son válidos", %{conn: conn} do
      conn = post(conn, ~p"/api/create_vehiculo", data: @valid_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      assert json_response(conn, 201)["data"] == %{
               "id" => id,
               "pos_x" => 10,
               "pos_y" => 20
             }
    end

    test "test con HTTP 422, no se pudo procesar la entidad, los datos son inválidos", %{
      conn: conn
    } do
      conn = post(conn, ~p"/api/create_vehiculo", data: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "GET /api/get_vehiculo/:id (READ)" do
    test "test con HTTP 200 para leer un rover de la base de datos y devolverlo", %{conn: conn} do
      {:ok, rover} = Rover.Vehiculo.create_vehiculo(@valid_attrs)

      conn = get(conn, ~p"/api/get_vehiculo/#{rover.id}")

      assert json_response(conn, 200)["data"]["id"] == rover.id
    end

    test "test con HTTP 404 para buscar un rover que no existe", %{conn: conn} do
      {:ok, rover} = Rover.Vehiculo.create_vehiculo(@valid_attrs)
      Rover.Vehiculo.delete_vehiculo(rover)

      conn = get(conn, ~p"/api/get_vehiculo/#{rover.id}")
      assert json_response(conn, 404) == %{"error" => "Rover not found"}
    end
  end

  describe "UPDATE /api/move_vehiculo/:id" do
    test "test con HTTP 200 para hacer un cambio en la posición del rover", %{conn: conn} do
      {:ok, rover} = Rover.Vehiculo.create_vehiculo(@valid_attrs)

      conn = patch(conn, ~p"/api/move_vehiculo/#{rover.id}", data: %{pos_x: 1})
      assert json_response(conn, 200)["data"]["pos_x"] == 1
    end

    test "test con HTTP 404 en caso de que el rover que se quiere modificar no exista", %{
      conn: conn
    } do
      {:ok, rover} = Rover.Vehiculo.create_vehiculo(@valid_attrs)
      Rover.Vehiculo.delete_vehiculo(rover)

      conn = patch(conn, ~p"/api/move_vehiculo/#{rover.id}", data: %{pos_x: 1})
      assert json_response(conn, 404) == %{"error" => "Rover not found"}
    end

    test "test en caso que de que haya un error en el changeset", %{conn: conn} do
      {:ok, rover} = Rover.Vehiculo.create_vehiculo(@valid_attrs)

      conn = patch(conn, ~p"/api/move_vehiculo/#{rover.id}", data: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "DELETE /api/delete_vehiculo/:id" do
    test "Eliminar con http 200 un rover basado en su id que sí exista", %{conn: conn} do
      {:ok, rover} = Rover.Vehiculo.create_vehiculo(@valid_attrs)
      conn = delete(conn, ~p"/api/delete_vehiculo/#{rover.id}")
      assert json_response(conn, 200) == %{"msg" => "Rover #{rover.id} lost connection"}
      assert Rover.Vehiculo.get_vehiculo(rover.id) == nil
    end

    test "Eliminar con con http 404 un rover que no existe", %{conn: conn} do
      {:ok, rover} = Rover.Vehiculo.create_vehiculo(@valid_attrs)
      Rover.Vehiculo.delete_vehiculo(rover)

      conn = delete(conn, ~p"/api/delete_vehiculo/#{rover.id}")
      assert json_response(conn, 404) == %{"error" => "Rover #{rover.id} not found"}
    end
  end

  describe "GET /api/get_all_vehiculos" do
    test "Traer todos los rovers con HTTP 200 con al menos un elemento", %{conn: conn} do
      {:ok, rover} = Rover.Vehiculo.create_vehiculo(@valid_attrs)
      conn = get(conn, ~p"/api/get_all_vehiculos")

      assert json_response(conn, 200)["data"] == [
               %{
                 "id" => rover.id,
                 "pos_x" => rover.pos_x,
                 "pos_y" => rover.pos_y
               }
             ]

      assert Enum.count(json_response(conn, 200)["data"]) != 0
    end

    test "Traer todos los rovers con HTTP 200 sin elementos", %{conn: conn} do
      conn = get(conn, ~p"/api/get_all_vehiculos")
      assert json_response(conn, 200)["data"] == []
      assert Enum.count(json_response(conn, 200)["data"]) == 0
    end
  end
end
