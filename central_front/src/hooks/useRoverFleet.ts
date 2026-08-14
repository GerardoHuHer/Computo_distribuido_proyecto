import { useCallback, useEffect, useState } from 'react'
import { createRover, deleteRover, getAllRovers, moveRover } from '../api/rover'
import { ApiError } from '../api/http'
import type { ConnectionStatus, Rover, RoverInput } from '../types/rover'

const DEFAULT_POLL_MS = 5000

export function useRoverFleet(pollIntervalMs = DEFAULT_POLL_MS) {
  const [rovers, setRovers] = useState<Rover[]>([])
  const [connection, setConnection] = useState<ConnectionStatus>('loading')
  const [error, setError] = useState<string | null>(null)
  const [lastSync, setLastSync] = useState<number | null>(null)

  const refresh = useCallback(async () => {
    try {
      const list = await getAllRovers()
      setRovers(list)
      setConnection('online')
      setLastSync(Date.now())
      setError(null)
    } catch (err) {
      setConnection('offline')
      setError(err instanceof ApiError ? err.message : 'No se pudo contactar con la estación central')
    }
  }, [])

  useEffect(() => {
    void refresh()
    const interval = setInterval(refresh, pollIntervalMs)
    return () => clearInterval(interval)
  }, [refresh, pollIntervalMs])

  const create = useCallback(
    async (input: RoverInput) => {
      const rover = await createRover(input)
      await refresh()
      return rover
    },
    [refresh],
  )

  const move = useCallback(async (id: string, input: { pos_x: number; pos_y: number }) => {
    const rover = await moveRover(id, input)
    setRovers((prev) => prev.map((r) => (r.id === id ? rover : r)))
    return rover
  }, [])

  const remove = useCallback(async (id: string) => {
    await deleteRover(id)
    setRovers((prev) => prev.filter((r) => r.id !== id))
  }, [])

  return { rovers, connection, error, lastSync, refresh, create, move, remove }
}
