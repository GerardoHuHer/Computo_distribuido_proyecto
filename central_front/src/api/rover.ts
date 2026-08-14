import { request } from './http'
import type { Rover, RoverInput } from '../types/rover'

interface RoverEnvelope {
  data: Rover
}

interface RoverListEnvelope {
  data: Rover[]
}

export function getAllRovers(): Promise<Rover[]> {
  return request<RoverListEnvelope>('/get_all_rovers/').then((res) => res.data)
}

export function createRover(input: RoverInput): Promise<Rover> {
  return request<RoverEnvelope>('/create_rover', {
    method: 'POST',
    body: JSON.stringify({ data: input }),
  }).then((res) => res.data)
}

export function getRover(id: string): Promise<Rover> {
  return request<RoverEnvelope>(`/get_rover/${id}`).then((res) => res.data)
}

export function moveRover(id: string, input: Pick<RoverInput, 'pos_x' | 'pos_y'>): Promise<Rover> {
  return request<RoverEnvelope>(`/move_rover/${id}`, {
    method: 'PATCH',
    body: JSON.stringify({ data: input }),
  }).then((res) => res.data)
}

export function deleteRover(id: string): Promise<{ msg: string }> {
  return request<{ msg: string }>(`/delete_rover/${id}`, { method: 'DELETE' })
}
