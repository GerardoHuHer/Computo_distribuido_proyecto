import type { Rover } from '../types/rover'
import { RoverIcon } from './icons'

interface FleetListProps {
  rovers: Rover[]
  selectedId: string | null
  onSelect: (id: string) => void
}

export function FleetList({ rovers, selectedId, onSelect }: FleetListProps) {
  if (rovers.length === 0) {
    return (
      <div className="fleet-empty">
        <RoverIcon className="fleet-empty-icon" />
        <p>No hay rovers activos.</p>
        <p className="muted">Despliega uno para empezar a monitorear la flota.</p>
      </div>
    )
  }

  return (
    <ul className="fleet-list">
      {rovers.map((rover) => (
        <li key={rover.id}>
          <button
            type="button"
            className={`fleet-item ${rover.id === selectedId ? 'is-active' : ''}`}
            onClick={() => onSelect(rover.id)}
          >
            <span className="status-dot status-dot--online" aria-hidden="true" />
            <span className="fleet-item-body">
              <span className="fleet-item-id">{rover.id.slice(0, 8)}</span>
              <span className="fleet-item-pos">
                X {rover.pos_x} · Y {rover.pos_y}
              </span>
            </span>
          </button>
        </li>
      ))}
    </ul>
  )
}
