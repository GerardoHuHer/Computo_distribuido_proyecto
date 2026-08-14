import { useEffect, useState } from 'react'
import { useRoverFleet } from './hooks/useRoverFleet'
import { Header } from './components/Header'
import { FleetList } from './components/FleetList'
import { RadarMap } from './components/RadarMap'
import { RoverDetail } from './components/RoverDetail'
import { AddRoverModal } from './components/AddRoverModal'
import './App.css'

function App() {
  const { rovers, connection, error, lastSync, refresh, create, move, remove } = useRoverFleet()
  const [selectedId, setSelectedId] = useState<string | null>(null)
  const [modalOpen, setModalOpen] = useState(false)

  useEffect(() => {
    if (selectedId && !rovers.some((r) => r.id === selectedId)) {
      setSelectedId(rovers[0]?.id ?? null)
    }
    if (!selectedId && rovers.length > 0) {
      setSelectedId(rovers[0].id)
    }
  }, [rovers, selectedId])

  const selected = rovers.find((r) => r.id === selectedId) ?? null

  return (
    <div className="shell">
      <Header rovers={rovers} connection={connection} onAdd={() => setModalOpen(true)} />

      {connection === 'offline' && (
        <div className="connection-banner" role="alert">
          Sin conexión con la estación central{error ? ` — ${error}` : ''}
        </div>
      )}

      <main className="layout">
        <aside className="panel fleet-panel">
          <h3 className="panel-title">Flota activa</h3>
          <FleetList rovers={rovers} selectedId={selectedId} onSelect={setSelectedId} />
        </aside>

        <section className="panel map-panel">
          <h3 className="panel-title">Mapa de posiciones</h3>
          <RadarMap rovers={rovers} selectedId={selectedId} onSelect={setSelectedId} />
        </section>

        <aside className="panel detail-panel">
          <RoverDetail
            rover={selected}
            connection={connection}
            lastSync={lastSync}
            onMove={move}
            onDelete={remove}
            onRefresh={refresh}
          />
        </aside>
      </main>

      {modalOpen && <AddRoverModal onClose={() => setModalOpen(false)} onCreate={create} />}
    </div>
  )
}

export default App
