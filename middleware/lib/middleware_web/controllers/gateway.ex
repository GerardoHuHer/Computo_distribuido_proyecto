defmodule MiddlewareWeb.Gateway do
  use MiddlewareWeb, :controller
  require Logger

  def gateway(conn, payload) do
    Logger.metadata(type: etiqueta(payload["type"]), action: etiqueta(payload["action"]))
    inicio = System.monotonic_time()
    conn = procesar(conn, payload)

    :telemetry.execute(
      [:middleware, :gateway, :stop],
      %{duration: System.monotonic_time() - inicio},
      %{type: etiqueta(payload["type"]), action: etiqueta(payload["action"]), status: conn.status}
    )

    conn
  end

  defp etiqueta(valor) when is_binary(valor), do: valor
  defp etiqueta(_valor), do: "invalido"

  defp procesar(conn, payload) do
    with :ok <- validar_payload(payload) do
      payload = payload |> Map.put_new("params", %{}) |> Observability.Trace.inject()

      case Middleware.Cola.encolar(payload, 30_000) do
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

        {:error, :sobrecargado} ->
          conn
          |> put_status(:service_unavailable)
          |> json(%{error: "Sistema sobrecargado"})

        {:error, reason} ->
          conn
          |> put_status(:bad_gateway)
          |> json(%{error: inspect(reason)})
      end
    else
      {_etiqueta, msg} ->
        conn
        |> put_status(:bad_request)
        |> json(msg)
    end
  end

  defp validar_payload(payload) do
    with :ok <- check_type(payload),
         :ok <- check_action(payload) do
      :ok
    end
  end

  defp check_type(%{"type" => type} = _payload) when is_binary(type) do
    :ok
  end

  defp check_type(_payload) do
    {:unvalid_type, %{"msg" => "El tipo no es válido"}}
  end

  defp check_action(%{"action" => action} = _payload) when is_binary(action) do
    :ok
  end

  defp check_action(_payload) do
    {:unvalid_action, %{"msg" => "La acción no es válida"}}
  end
end
