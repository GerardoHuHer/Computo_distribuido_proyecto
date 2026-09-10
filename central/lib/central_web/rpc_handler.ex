defmodule CentralWeb.RpcHandler do
  # alias CentralWeb.Handlers.VehiculoHandler
  alias CentralWeb.Handlers.EventosHandler

  def handle_request("recibir_evento", params),
    do: EventosHandler.handle_request("recibir_evento", params)

  def handle_request(unknow_action, _params) do
    {:error, {:unknow_action, unknow_action}}
  end
end
