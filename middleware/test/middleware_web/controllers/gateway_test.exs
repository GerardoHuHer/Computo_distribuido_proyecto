defmodule MiddlewareWeb.GatewayTest do
  use Middleware.ConnCase, async: true

  @valid_payload %{
    type: "rover",
    action: "alguna_accion",
    params: %{clave: "valor"}
  }

  @invalid_payload_type %{
    action: "alguna_accion",
    params: %{clave: "valor"}
  }

  @invalid_payload_action %{
    type: "alguna_accion",
    params: %{clave: "valor"}
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "POST middleware/api/gateway" do
    test "Error falta de type", %{conn: conn} do
      conn = post(conn, "/api/gateway", @invalid_payload_type)
    end
  end
end
