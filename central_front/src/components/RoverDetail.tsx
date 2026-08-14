import { useEffect, useState } from 'react'
import type { FormEvent } from 'react'
import type { ConnectionStatus, Rover } from '../types/rover'
import { ArrowIcon, RefreshIcon, SignalIcon, TargetIcon, TrashIcon } from './icons'

interface RoverDetailProps {
  rover: Rover | null
  connection: ConnectionStatus
  lastSync: number | null
  onMove: (id: string, next: { pos_x: number; pos_y: number }) => Promise<unknown>
  onDelete: (id: string) => Promise<void>
  onRefresh: () => void
}

const STEPS = [1, 5, 10]

function relativeTime(timestamp: number | null): string {
  if (!timestamp) return 'sin datos'
  const seconds = Math.max(0, Math.round((Date.now() - timestamp) / 1000))
  if (seconds < 2) return 'justo ahora'
  if (seconds < 60) return `hace ${seconds}s`
  const minutes = Math.round(seconds / 60)
  return `hace ${minutes}m`
}

export function RoverDetail({ rover, connection, lastSync, onMove, onDelete, onRefresh }: RoverDetailProps) {
  const [step, setStep] = useState(1)
  const [manualX, setManualX] = useState('0')
  const [manualY, setManualY] = useState('0')
  const [busy, setBusy] = useState(false)
  const [actionError, setActionError] = useState<string | null>(null)
  const [confirmingDelete, setConfirmingDelete] = useState(false)

  useEffect(() => {
    if (rover) {
      setManualX(String(rover.pos_x))
      setManualY(String(rover.pos_y))
    }
    setConfirmingDelete(false)
    setActionError(null)
  }, [rover?.id, rover?.pos_x, rover?.pos_y])

  if (!rover) {
    return (
      <div className="detail-empty">
        <TargetIcon className="detail-empty-icon" />
        <p>Selecciona un rover en la flota o en el mapa para ver su telemetría.</p>
      </div>
    )
  }

  const disabled = busy || connection === 'loading'

  const nudge = async (dx: number, dy: number) => {
    setBusy(true)
    setActionError(null)
    try {
      await onMove(rover.id, { pos_x: rover.pos_x + dx, pos_y: rover.pos_y + dy })
    } catch (err) {
      setActionError(err instanceof Error ? err.message : 'No se pudo mover el rover')
    } finally {
      setBusy(false)
    }
  }

  const submitManual = async (event: FormEvent) => {
    event.preventDefault()
    const pos_x = Number(manualX)
    const pos_y = Number(manualY)
    if (!Number.isFinite(pos_x) || !Number.isFinite(pos_y)) {
      setActionError('Coordenadas inválidas')
      return
    }
    setBusy(true)
    setActionError(null)
    try {
      await onMove(rover.id, { pos_x, pos_y })
    } catch (err) {
      setActionError(err instanceof Error ? err.message : 'No se pudo mover el rover')
    } finally {
      setBusy(false)
    }
  }

  const handleDelete = async () => {
    setBusy(true)
    setActionError(null)
    try {
      await onDelete(rover.id)
    } catch (err) {
      setActionError(err instanceof Error ? err.message : 'No se pudo eliminar el rover')
      setBusy(false)
    }
  }

  return (
    <div className="detail">
      <div className="detail-header">
        <div>
          <p className="detail-eyebrow">Rover</p>
          <h2 className="detail-id" title={rover.id}>
            {rover.id.slice(0, 8)}
          </h2>
        </div>
        <span className={`status-pill status-pill--${connection === 'offline' ? 'offline' : 'online'}`}>
          <SignalIcon />
          {connection === 'offline' ? 'Sin conexión' : 'Activo'}
        </span>
      </div>

      <p className="detail-sync">Última actualización de la flota: {relativeTime(lastSync)}</p>

      <div className="telemetry-grid">
        <div className="telemetry-cell">
          <span className="telemetry-label">Posición X</span>
          <span className="telemetry-value">{rover.pos_x}</span>
        </div>
        <div className="telemetry-cell">
          <span className="telemetry-label">Posición Y</span>
          <span className="telemetry-value">{rover.pos_y}</span>
        </div>
      </div>

      <div className="control-block">
        <div className="control-block-head">
          <h3>Control de movimiento</h3>
          <div className="step-toggle">
            {STEPS.map((value) => (
              <button
                key={value}
                type="button"
                className={value === step ? 'is-active' : ''}
                onClick={() => setStep(value)}
              >
                {value}
              </button>
            ))}
          </div>
        </div>

        <div className="dpad">
          <button
            type="button"
            className="dpad-btn dpad-up"
            disabled={disabled}
            onClick={() => nudge(0, step)}
            aria-label="Mover arriba"
          >
            <ArrowIcon />
          </button>
          <button
            type="button"
            className="dpad-btn dpad-left"
            disabled={disabled}
            onClick={() => nudge(-step, 0)}
            aria-label="Mover izquierda"
          >
            <ArrowIcon style={{ transform: 'rotate(-90deg)' }} />
          </button>
          <span className="dpad-center">
            <TargetIcon />
          </span>
          <button
            type="button"
            className="dpad-btn dpad-right"
            disabled={disabled}
            onClick={() => nudge(step, 0)}
            aria-label="Mover derecha"
          >
            <ArrowIcon style={{ transform: 'rotate(90deg)' }} />
          </button>
          <button
            type="button"
            className="dpad-btn dpad-down"
            disabled={disabled}
            onClick={() => nudge(0, -step)}
            aria-label="Mover abajo"
          >
            <ArrowIcon style={{ transform: 'rotate(180deg)' }} />
          </button>
        </div>

        <form className="manual-form" onSubmit={submitManual}>
          <label>
            X
            <input
              type="number"
              value={manualX}
              onChange={(event) => setManualX(event.target.value)}
              disabled={disabled}
            />
          </label>
          <label>
            Y
            <input
              type="number"
              value={manualY}
              onChange={(event) => setManualY(event.target.value)}
              disabled={disabled}
            />
          </label>
          <button type="submit" disabled={disabled} className="btn btn-secondary">
            Fijar posición
          </button>
        </form>
      </div>

      {actionError && <p className="detail-error">{actionError}</p>}

      <div className="detail-actions">
        <button type="button" className="btn btn-ghost" onClick={onRefresh} disabled={busy}>
          <RefreshIcon /> Actualizar
        </button>

        {!confirmingDelete ? (
          <button type="button" className="btn btn-danger" onClick={() => setConfirmingDelete(true)} disabled={busy}>
            <TrashIcon /> Eliminar rover
          </button>
        ) : (
          <div className="confirm-row">
            <span>¿Confirmar pérdida de contacto?</span>
            <button type="button" className="btn btn-danger" onClick={handleDelete} disabled={busy}>
              Sí, eliminar
            </button>
            <button type="button" className="btn btn-ghost" onClick={() => setConfirmingDelete(false)} disabled={busy}>
              Cancelar
            </button>
          </div>
        )}
      </div>
    </div>
  )
}
