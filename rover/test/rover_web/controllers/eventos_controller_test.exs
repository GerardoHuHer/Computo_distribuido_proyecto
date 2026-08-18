defmodule RoverWeb.EventosControllerTest do
  use Rover.Conncase, async: true

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "GET /api/load_eventos_db" do
    test "load_eventos_db_controller para la carga de 100 registros exitoso", %{conn: conn} do
      conn = get("/api/load_eventos_db")
      assert json_response(conn, 200) == %{"msg" => "Se han añadido los 100 eventos con éxito"}
    end
  end

  describe "GET /api/get_evento_random" do
    test "get_evento_random al obtener un registro", %{conn: conn} do
      conn = get("/api/get_evento_random")
      assert json_response(conn, 200)["data"] = %{id, name, description}
    end
  end
end
