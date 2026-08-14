import type { ConnectionStatus, Rover } from '../types/rover'
import { PlusIcon, RoverIcon } from './icons'

interface HeaderProps {
  rovers: Rover[]
  connection: ConnectionStatus
  onAdd: () => void
}

export function Header({ rovers, connection, onAdd }: HeaderProps) {
  return (
    <header className="app-header">
      <div className="brand">
        <span className="brand-mark">
          <RoverIcon />
        </span>
        <div>
          <p className="brand-name">Central de Comando</p>
          <p className="brand-sub">Monitoreo de flota de rovers</p>
        </div>
      </div>

      <div className="header-actions">
        <span className="fleet-summary">
          <span className="fleet-summary-dot" data-active={connection === 'online'} />
          {connection === 'offline' ? 'Sin conexión' : `${rovers.length} rover${rovers.length === 1 ? '' : 's'} activo${rovers.length === 1 ? '' : 's'}`}
        </span>
        <button type="button" className="btn btn-primary" onClick={onAdd}>
          <PlusIcon /> Nuevo rover
        </button>
      </div>
    </header>
  )
}
