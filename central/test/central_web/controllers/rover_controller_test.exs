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

  describe "POST /api/rover (create)" do
    test "test con HTTP 201, lo crea cuando los datos son válidos", %{conn: conn} do
      conn = post(conn, ~p"/api/rover", data: @valid_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      assert json_response(conn, 201)["data"] == %{
               "id" => id,
               "pos_x" => 10,
               "pos_y" => 20,
               "timestamp" => "2026-08-12T23:00:00Z"
             }
    end

    test "test con HTTP 422, no se pudo procesar la entidad, los datos son inválidos", %{
      conn: conn
    } do
      conn = post(conn, ~p"/api/rover", data: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
