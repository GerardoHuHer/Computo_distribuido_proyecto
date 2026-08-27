defmodule MiddlewareWeb.Gateway do
  use MiddlewareWeb, :controller

  def gateway(conn, payload) do
    case GenServer.call(Middleware.RequestQueue, {:encolar, payload}) do
      {:ok, data} ->
        conn
        |> put_status(:ok)
        |> json(data)

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "no encontrado"})

      {:error, :no_backend_disponible} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{error: "Sin backends disponibles"})

      {:error, reason} ->
        conn
        |> put_status(:bad_gateway)
        |> json(%{error: inspect(reason)})
    end
  end
end
