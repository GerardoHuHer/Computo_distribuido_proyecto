// Cliente para el gateway del middleware.
//
// El middleware expone un único endpoint POST /api/gateway que recibe
// { type, action, params } y lo reencola hacia el backend (rover, inventario
// o central) que esté libre. Ver middleware/lib/middleware_web/controllers/gateway.ex
// y middleware/lib/middleware/request_queue.ex.
export type BackendType = "rover" | "inventario" | "central";

export interface GatewaySuccess<T = unknown> {
  ok: true;
  status: number;
  data: T;
}

export interface GatewayFailure {
  ok: false;
  status: number;
  message: string;
}

export type GatewayResult<T = unknown> = GatewaySuccess<T> | GatewayFailure;

// Se deja relativo a propósito: en dev, vite.config.ts proxya /api hacia el
// middleware (evita CORS); en producción, nginx.conf hace el mismo proxy.
const GATEWAY_URL = "/api/gateway";

export async function callGateway<T = unknown>(
  type: BackendType,
  action: string,
  params: Record<string, unknown> = {},
): Promise<GatewayResult<T>> {
  let res: Response;
  try {
    res = await fetch(GATEWAY_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ type, action, params }),
    });
  } catch {
    return {
      ok: false,
      status: 0,
      message: "no se pudo contactar al middleware (¿está levantado?)",
    };
  }

  let body: unknown = null;
  try {
    body = await res.json();
  } catch {
    // Respuesta sin cuerpo JSON, se ignora y se usa el status.
  }

  if (!res.ok) {
    return {
      ok: false,
      status: res.status,
      message: extractErrorMessage(body, res.status),
    };
  }

  return { ok: true, status: res.status, data: body as T };
}

function extractErrorMessage(body: unknown, status: number): string {
  if (body && typeof body === "object" && "error" in body) {
    const err = (body as { error: unknown }).error;
    return typeof err === "string" ? err : JSON.stringify(err);
  }
  return `HTTP ${status}`;
}
