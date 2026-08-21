defmodule RoverWeb.EventosControllerTest do
  use RoverWeb.ConnCase, async: true

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "GET /api/load_eventos_db" do
    test "load_eventos_db_controller para la carga de 100 registros exitoso", %{conn: conn} do
      conn = get(conn, "/api/load_eventos_db")
      assert json_response(conn, 200) == %{"msg" => "Se han añadido los 100 eventos con éxito"}
    end
  end

  describe "GET /api/get_evento_random" do
    test "get_evento_random al obtener un registro", %{conn: conn} do
      conn = get(conn, "/api/get_evento_random")

      assert %{"data" => %{"id" => id, "name" => name, "description" => description}} =
               json_response(conn, 200)

      assert is_integer(id)
      assert is_binary(name)
      assert is_binary(description)
    end
  end
end
