defmodule RoverWeb.RpcHandler do
  alias RoverWeb.Handlers.VehiculoHandler
  alias RoverWeb.Handlers.EventosHandler

  def handle_request("create_rover", params),
    do: VehiculoHandler.handle_request("create_rover", params)

  def handle_request("get_evento_random", params),
    do: EventosHandler.handle_request("get_evento_random", params)

  def handle_request(unknow_action, _params) do
    {:error, {:unknow_action, unknow_action}}
  end
end
