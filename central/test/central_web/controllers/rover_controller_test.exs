defmodule CentralWeb.RoverControllerTest do
  use CentralWeb.ConnCase, async: true

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

  describe "POST /api/create_rover (create)" do
    test "test con HTTP 201, lo crea cuando los datos son válidos", %{conn: conn} do
      conn = post(conn, ~p"/api/create_rover", data: @valid_attrs)
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
      conn = post(conn, ~p"/api/create_rover", data: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "GET /api/get_rover/:id (READ)" do
    test "test con HTTP 200 para leer un rover de la base de datos y devolverlo", %{conn: conn} do
      {:ok, rover} = Central.Rover.create_rover(@valid_attrs)

      conn = get(conn, ~p"/api/get_rover/#{rover.id}")

      assert json_response(conn, 200)["data"]["id"] == rover.id
    end
  end

  describe "UPDATE /api/move_rover/:id" do
    test "test con HTTP 200 para hacer un cambio en la posición del rover", %{conn: conn} do
      {:ok, rover} = Central.Rover.create_rover(@valid_attrs)

      conn = patch(conn, ~p"/api/move_rover/#{rover.id}", data: %{pos_x: 1})
      assert json_response(conn, 200)["data"]["pos_x"] == 1
    end
  end

  describe "DELETE /api/delete_rover/:id" do
    test "Eliminar con http 200 un rover basado en su id que sí exista", %{conn: conn} do
      {:ok, rover} = Central.Rover.create_rover(@valid_attrs)
      conn = delete(conn, ~p"/api/delete_rover/#{rover.id}")
      assert json_response(conn, 200) == %{"msg" => "Rover #{rover.id} lost connection"}
      assert Central.Rover.get_rover(rover.id) == nil
    end
  end
end
