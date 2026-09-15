import { useEffect, useRef, useState } from "react";
import { execute, formatTable, type OutputBlock } from "../lib/commands";

const PROMPT = "root@middleware:~$";

interface HistoryEntry {
  id: number;
  command: string;
  blocks: OutputBlock[];
  pending: boolean;
}

let nextId = 0;

function Block({ block }: { block: OutputBlock }) {
  if (block.kind === "table") {
    return <pre className="term-block term-table">{formatTable(block.columns, block.rows)}</pre>;
  }
  return (
    <div className={`term-block term-line${block.tone ? ` term-${block.tone}` : ""}`}>
      {block.text}
    </div>
  );
}

export default function Terminal() {
  const [history, setHistory] = useState<HistoryEntry[]>([]);
  const [input, setInput] = useState("");
  const [busy, setBusy] = useState(false);
  const [focused, setFocused] = useState(true);
  const [cmdLog, setCmdLog] = useState<string[]>([]);
  const [cmdIndex, setCmdIndex] = useState<number | null>(null);

  const scrollRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    const el = scrollRef.current;
    if (el) el.scrollTop = el.scrollHeight;
  }, [history, input]);

  useEffect(() => {
    // Un <input disabled> pierde el foco automáticamente en el navegador;
    // al reactivarlo hay que devolvérselo o el teclado deja de responder.
    if (!busy) inputRef.current?.focus();
  }, [busy]);

  async function submit() {
    const raw = input;
    const trimmed = raw.trim();
    setInput("");
    setCmdIndex(null);

    if (trimmed.length === 0) return;

    if (trimmed.toLowerCase() === "clear") {
      setHistory([]);
      setCmdLog((log) => [...log, trimmed]);
      return;
    }

    setCmdLog((log) => [...log, trimmed]);

    const id = nextId++;
    setHistory((h) => [...h, { id, command: raw, blocks: [], pending: true }]);
    setBusy(true);

    const blocks = await execute(trimmed);

    setHistory((h) => h.map((entry) => (entry.id === id ? { ...entry, blocks, pending: false } : entry)));
    setBusy(false);
  }

  function handleKeyDown(e: React.KeyboardEvent<HTMLInputElement>) {
    if (e.key === "Enter") {
      e.preventDefault();
      if (!busy) void submit();
      return;
    }
    if (e.key === "ArrowUp") {
      e.preventDefault();
      if (cmdLog.length === 0) return;
      const nextIndex = cmdIndex === null ? cmdLog.length - 1 : Math.max(0, cmdIndex - 1);
      setCmdIndex(nextIndex);
      setInput(cmdLog[nextIndex]);
      return;
    }
    if (e.key === "ArrowDown") {
      e.preventDefault();
      if (cmdIndex === null) return;
      const nextIndex = cmdIndex + 1;
      if (nextIndex >= cmdLog.length) {
        setCmdIndex(null);
        setInput("");
      } else {
        setCmdIndex(nextIndex);
        setInput(cmdLog[nextIndex]);
      }
    }
  }

  return (
    <div className="terminal-window" onClick={() => inputRef.current?.focus()}>

      <div className="terminal-body" ref={scrollRef}>
        <div className="term-block term-line term-info">
          Terminal de control del middleware. Escribe "help" para ver los comandos disponibles.
        </div>

        {history.map((entry) => (
          <div key={entry.id} className="terminal-entry">
            <div className="term-block term-line term-echo">
              <span className="term-prompt">{PROMPT}</span> {entry.command}
            </div>
            {entry.pending ? (
              <div className="term-block term-line term-info">…</div>
            ) : (
              entry.blocks.map((block, i) => <Block key={i} block={block} />)
            )}
          </div>
        ))}

        <div className="terminal-input-line">
          <span className="term-prompt">{PROMPT}</span>
          <span className="term-typed">
            {input}
            <span className={`term-cursor${focused ? " term-cursor-blink" : ""}`} />
          </span>
          <input
            ref={inputRef}
            className="term-hidden-input"
            value={input}
            disabled={busy}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={handleKeyDown}
            onFocus={() => setFocused(true)}
            onBlur={() => setFocused(false)}
            autoFocus
            autoComplete="off"
            autoCapitalize="off"
            autoCorrect="off"
            spellCheck={false}
          />
        </div>
      </div>
    </div>
  );
}
