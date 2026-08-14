import type { Rover } from '../types/rover'

interface RadarMapProps {
  rovers: Rover[]
  selectedId: string | null
  onSelect: (id: string) => void
}

const VIEW = 400
const MARGIN = 36

function niceStep(range: number): number {
  const raw = range / 6
  const magnitude = 10 ** Math.floor(Math.log10(Math.max(raw, 1)))
  const normalized = raw / magnitude
  const step = normalized >= 5 ? 5 : normalized >= 2 ? 2 : 1
  return step * magnitude
}

export function RadarMap({ rovers, selectedId, onSelect }: RadarMapProps) {
  const bounds = (() => {
    const xs = rovers.map((r) => r.pos_x).concat(0)
    const ys = rovers.map((r) => r.pos_y).concat(0)
    const minX = Math.min(...xs)
    const maxX = Math.max(...xs)
    const minY = Math.min(...ys)
    const maxY = Math.max(...ys)
    const spanX = Math.max(maxX - minX, 10)
    const spanY = Math.max(maxY - minY, 10)
    const pad = Math.max(spanX, spanY) * 0.25 + 2
    return {
      minX: minX - pad,
      maxX: maxX + pad,
      minY: minY - pad,
      maxY: maxY + pad,
    }
  })()

  const toSvg = (x: number, y: number) => {
    const rangeX = bounds.maxX - bounds.minX
    const rangeY = bounds.maxY - bounds.minY
    const px = MARGIN + ((x - bounds.minX) / rangeX) * (VIEW - MARGIN * 2)
    const py = VIEW - MARGIN - ((y - bounds.minY) / rangeY) * (VIEW - MARGIN * 2)
    return [px, py]
  }

  const stepX = niceStep(bounds.maxX - bounds.minX)
  const stepY = niceStep(bounds.maxY - bounds.minY)

  const vLines: number[] = []
  for (let x = Math.ceil(bounds.minX / stepX) * stepX; x <= bounds.maxX; x += stepX) vLines.push(x)
  const hLines: number[] = []
  for (let y = Math.ceil(bounds.minY / stepY) * stepY; y <= bounds.maxY; y += stepY) hLines.push(y)

  const [originX, originY] = toSvg(0, 0)

  return (
    <div className="radar">
      <svg viewBox={`0 0 ${VIEW} ${VIEW}`} className="radar-svg" role="img" aria-label="Mapa de posiciones de la flota">
        <rect x="0" y="0" width={VIEW} height={VIEW} className="radar-bg" />

        {vLines.map((x) => {
          const [px] = toSvg(x, 0)
          return (
            <line
              key={`v-${x}`}
              x1={px}
              y1={MARGIN}
              x2={px}
              y2={VIEW - MARGIN}
              className={x === 0 ? 'radar-axis' : 'radar-grid'}
            />
          )
        })}
        {hLines.map((y) => {
          const [, py] = toSvg(0, y)
          return (
            <line
              key={`h-${y}`}
              x1={MARGIN}
              y1={py}
              x2={VIEW - MARGIN}
              y2={py}
              className={y === 0 ? 'radar-axis' : 'radar-grid'}
            />
          )
        })}

        <g className="radar-origin">
          <path
            d={`M ${originX} ${originY - 7} L ${originX + 7} ${originY} L ${originX} ${originY + 7} L ${originX - 7} ${originY} Z`}
          />
          <text x={originX} y={originY + 20} textAnchor="middle" className="radar-origin-label">
            BASE
          </text>
        </g>

        {rovers.map((rover) => {
          const [px, py] = toSvg(rover.pos_x, rover.pos_y)
          const isSelected = rover.id === selectedId
          return (
            <g
              key={rover.id}
              className={`radar-blip ${isSelected ? 'is-selected' : ''}`}
              transform={`translate(${px} ${py})`}
              onClick={() => onSelect(rover.id)}
              role="button"
              tabIndex={0}
              aria-label={`Rover ${rover.id}`}
              onKeyDown={(event) => {
                if (event.key === 'Enter' || event.key === ' ') onSelect(rover.id)
              }}
            >
              {isSelected && <circle r="14" className="radar-blip-ring" />}
              <circle r="6" className="radar-blip-dot" />
              <text y="-12" textAnchor="middle" className="radar-blip-label">
                {rover.id.slice(0, 6)}
              </text>
            </g>
          )
        })}
      </svg>

      {rovers.length === 0 && (
        <div className="radar-empty">
          <p>Sin rovers en rango. Crea uno para verlo en el mapa.</p>
        </div>
      )}
    </div>
  )
}
