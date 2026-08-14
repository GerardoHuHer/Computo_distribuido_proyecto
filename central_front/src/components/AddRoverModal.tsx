import { useState } from 'react'
import type { FormEvent } from 'react'
import type { RoverInput } from '../types/rover'
import { CloseIcon } from './icons'

interface AddRoverModalProps {
  onClose: () => void
  onCreate: (input: RoverInput) => Promise<unknown>
}

export function AddRoverModal({ onClose, onCreate }: AddRoverModalProps) {
  const [posX, setPosX] = useState('0')
  const [posY, setPosY] = useState('0')
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const submitCreate = async (event: FormEvent) => {
    event.preventDefault()
    const pos_x = Number(posX)
    const pos_y = Number(posY)
    if (!Number.isFinite(pos_x) || !Number.isFinite(pos_y)) {
      setError('Coordenadas inválidas')
      return
    }
    setBusy(true)
    setError(null)
    try {
      await onCreate({ pos_x, pos_y })
      onClose()
    } catch (err) {
      setError(err instanceof Error ? err.message : 'No se pudo desplegar el rover')
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className="modal-backdrop" onClick={onClose}>
      <div
        className="modal"
        role="dialog"
        aria-modal="true"
        aria-labelledby="add-rover-title"
        onClick={(event) => event.stopPropagation()}
      >
        <div className="modal-header">
          <h2 id="add-rover-title">Desplegar nuevo rover</h2>
          <button type="button" className="icon-btn" onClick={onClose} aria-label="Cerrar">
            <CloseIcon />
          </button>
        </div>

        <form onSubmit={submitCreate} className="modal-form">
          <p className="muted">Registra un nuevo rover en la base de datos central con una posición inicial.</p>
          <div className="field-row">
            <label>
              Posición X
              <input type="number" value={posX} onChange={(event) => setPosX(event.target.value)} disabled={busy} />
            </label>
            <label>
              Posición Y
              <input type="number" value={posY} onChange={(event) => setPosY(event.target.value)} disabled={busy} />
            </label>
          </div>
          {error && <p className="detail-error">{error}</p>}
          <button type="submit" className="btn btn-primary" disabled={busy}>
            {busy ? 'Desplegando…' : 'Desplegar rover'}
          </button>
        </form>
      </div>
    </div>
  )
}
