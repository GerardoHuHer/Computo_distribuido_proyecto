defmodule InventarioWeb.RpcHandler do
  alias InventarioWeb.Handlers.Items

  def handle_request("create_item", params),
    do: Items.handle_request("create_item", params)

  def handle_request("get_items", params),
    do: Items.handle_request("get_items", params)

  def handle_request("update_item", params),
    do: Items.handle_request("update_item", params)

  def handle_request("delete_item", params),
    do: Items.handle_request("delete_item", params)

  def handle_request(unknow_action, _params) do
    {:error, {:unknow_action, unknow_action}}
  end
end
