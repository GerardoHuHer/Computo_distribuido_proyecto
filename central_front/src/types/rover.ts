export interface Rover {
  id: string
  pos_x: number
  pos_y: number
}

export interface RoverInput {
  pos_x: number
  pos_y: number
  timestamp?: string
}

export interface ApiErrorPayload {
  error?: string
  errors?: Record<string, string[]>
  msg?: string
}

export type ConnectionStatus = 'loading' | 'online' | 'offline'
