defmodule CentralWeb.RpcHandler do
  # alias CentralWeb.Handlers.VehiculoHandler
  alias CentralWeb.Handlers.EventosHandler

  def handle_request("recibir_evento", params),
    do: EventosHandler.handle_request("recibir_evento", params)

  def handle_request("read_all_events", params),
    do: EventosHandler.handle_request("read_all_events", params)

  def handle_request("update_event", params),
    do: EventosHandler.handle_request("update_event", params)

  def handle_request("delete_event", params),
    do: EventosHandler.handle_request("delete_event", params)

  def handle_request(unknow_action, _params) do
    {:error, {:unknow_action, unknow_action}}
  end
end
