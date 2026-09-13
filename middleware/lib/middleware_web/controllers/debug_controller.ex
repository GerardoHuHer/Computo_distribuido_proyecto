defmodule MiddlewareWeb.DebugController do
  use MiddlewareWeb, :controller

  def nodos(conn, _params) do
    agrupados =
      Node.list()
      |> Enum.group_by(fn nodo ->
        nodo |> Atom.to_string() |> String.split("@") |> List.first()
      end)
      |> Enum.map(fn {tipo, nodos} -> {tipo, Enum.map(nodos, &Atom.to_string/1)} end)
      |> Map.new()

    json(conn, agrupados)
  end
end
