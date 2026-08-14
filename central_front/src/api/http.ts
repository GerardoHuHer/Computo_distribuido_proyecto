import type { ApiErrorPayload } from '../types/rover'

const API_BASE = '/api'

export class ApiError extends Error {
  status: number
  payload: unknown

  constructor(message: string, status: number, payload: unknown) {
    super(message)
    this.name = 'ApiError'
    this.status = status
    this.payload = payload
  }
}

function extractErrorMessage(body: unknown): string | null {
  if (!body || typeof body !== 'object') return null
  const payload = body as ApiErrorPayload

  if (payload.error) return payload.error

  if (payload.errors) {
    const first = Object.entries(payload.errors)[0]
    if (first) {
      const [field, messages] = first
      return `${field} ${messages[0]}`
    }
  }

  return null
}

export async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  let response: Response

  try {
    response = await fetch(`${API_BASE}${path}`, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
        ...options.headers,
      },
    })
  } catch {
    throw new ApiError('No se pudo contactar con la estación central', 0, null)
  }

  const isJson = response.headers.get('content-type')?.includes('application/json') ?? false
  const body = isJson ? await response.json().catch(() => null) : null

  if (!response.ok) {
    throw new ApiError(extractErrorMessage(body) ?? `Error ${response.status}`, response.status, body)
  }

  return body as T
}
