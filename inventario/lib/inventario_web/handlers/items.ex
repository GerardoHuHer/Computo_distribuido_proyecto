defmodule InventarioWeb.Handlers.Items do
  alias Inventario.Inventario

  def handle_request("create_item", params) do
    case Inventario.create_item(params) do
      {:ok, inventario} ->
        {:ok, data(inventario)}

      {:error, changeset} ->
        {:error, %{changeset: changeset}}
    end
  end

  def handle_request("get_items", _params) do
    inventario = Inventario.read_inventory()
    {:ok, for(i <- inventario, do: data(i))}
  end

  def handle_request("update_item", params) do
    with {:ok, item} <- fetch_item(params["id"]),
         {:ok, updated_item} <- Inventario.update_item(item, params) do
      {:ok, data(updated_item)}
    else
      {:error, :not_found} ->
        {:error, %{msg: "Item not found"}}

      {:error, changeset} ->
        {:error, %{msg: changeset}}
    end
  end

  def handle_request("delete_item", params) do
    with {:ok, item} <- fetch_item(params["id"]),
         {:ok, _} <- Inventario.delete_item(item) do
      {:ok, %{msg: "Item: #{item} was deleted"}}
    else
      {:error, :not_found} ->
        {:error, %{msg: "Item not found"}}
    end
  end

  defp data(%Inventario.Inventario{} = inventario) do
    %{
      id: inventario.id,
      name: inventario.name,
      description: inventario.description,
      cantidad: inventario.cantidad,
      prioridad: inventario.prioridad
    }
  end

  defp fetch_item(id) do
    case Inventario.get_one_item(id) do
      nil -> {:error, :not_found}
      item -> {:ok, item}
    end
  end
end
