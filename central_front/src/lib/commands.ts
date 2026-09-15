import { callGateway, type BackendType } from "./api";

export type OutputBlock =
  | { kind: "line"; text: string; tone?: "error" | "info" | "success" }
  | { kind: "table"; columns: string[]; rows: Array<Array<string | number>> };

class CommandError extends Error {}

interface CommandSpec {
  usage: string;
  run: (args: string[]) => Promise<OutputBlock[]>;
}

// Soporta comillas simples/dobles para argumentos con espacios, ej:
// create inventario "Panel solar" "Repuesto de rover" 10 3
function tokenize(line: string): string[] {
  const tokens: string[] = [];
  const re = /"([^"]*)"|'([^']*)'|(\S+)/g;
  let m: RegExpExecArray | null;
  while ((m = re.exec(line)) !== null) {
    tokens.push(m[1] ?? m[2] ?? m[3]);
  }
  return tokens;
}

function requireArgs(args: string[], names: string[], usage: string): string[] {
  if (args.length < names.length) {
    throw new CommandError(`uso: ${usage}`);
  }
  return names.map((_, i) => args[i]);
}

function num(value: string, label: string): number {
  const n = Number(value);
  if (!Number.isFinite(n)) {
    throw new CommandError(`"${label}" debe ser un número, se recibió "${value}"`);
  }
  return n;
}

function formatCell(value: unknown): string | number {
  if (value === null || value === undefined) return "";
  if (typeof value === "boolean") return value ? "true" : "false";
  if (typeof value === "number" || typeof value === "string") return value;
  return JSON.stringify(value);
}

function errorBlock(status: number, message: string): OutputBlock[] {
  return [{ kind: "line", tone: "error", text: `error (${status}): ${message}` }];
}

async function callAndTable(
  type: BackendType,
  action: string,
  params: Record<string, unknown>,
  columns: string[],
  single = false,
): Promise<OutputBlock[]> {
  const res = await callGateway(type, action, params);
  if (!res.ok) return errorBlock(res.status, res.message);

  const rows = single ? [res.data] : res.data;
  if (!Array.isArray(rows)) {
    return [{ kind: "line", tone: "error", text: "respuesta inesperada del backend" }];
  }
  if (rows.length === 0) {
    return [{ kind: "line", tone: "info", text: "(sin resultados)" }];
  }

  const tableRows = rows.map((row) =>
    columns.map((col) => formatCell((row as Record<string, unknown>)?.[col])),
  );
  return [{ kind: "table", columns, rows: tableRows }];
}

async function callAndMessage(
  type: BackendType,
  action: string,
  params: Record<string, unknown>,
): Promise<OutputBlock[]> {
  const res = await callGateway(type, action, params);
  if (!res.ok) return errorBlock(res.status, res.message);

  const data = res.data as { msg?: string } | string | null;
  const text = typeof data === "string" ? data : data?.msg ?? JSON.stringify(data);
  return [{ kind: "line", tone: "success", text }];
}

const ROVER_COLUMNS = ["id", "pos_x", "pos_y"];
const EVENTO_COLUMNS = ["name", "description", "pos_x", "pos_y"];
const INVENTARIO_COLUMNS = ["id", "name", "description", "cantidad", "prioridad"];
const CENTRAL_COLUMNS = ["id", "name", "description", "pos_x", "pos_y"];

const COMMANDS: Record<string, CommandSpec> = {
  "list rover": {
    usage: "list rover",
    run: async () => callAndTable("rover", "get_all_vehiculos", {}, ROVER_COLUMNS),
  },
  "get rover": {
    usage: "get rover <id>",
    run: async (args) => {
      const [id] = requireArgs(args, ["id"], "get rover <id>");
      return callAndTable("rover", "get_vehiculo", { id }, ROVER_COLUMNS, true);
    },
  },
  "create rover": {
    usage: "create rover <pos_x> <pos_y>",
    run: async (args) => {
      const [posX, posY] = requireArgs(args, ["pos_x", "pos_y"], "create rover <pos_x> <pos_y>");
      return callAndTable(
        "rover",
        "create_rover",
        { pos_x: num(posX, "pos_x"), pos_y: num(posY, "pos_y") },
        ROVER_COLUMNS,
        true,
      );
    },
  },
  "move rover": {
    usage: "move rover <id> <pos_x> <pos_y>",
    run: async (args) => {
      const [id, posX, posY] = requireArgs(
        args,
        ["id", "pos_x", "pos_y"],
        "move rover <id> <pos_x> <pos_y>",
      );
      return callAndTable(
        "rover",
        "move_vehiculo",
        { id, pos_x: num(posX, "pos_x"), pos_y: num(posY, "pos_y") },
        ROVER_COLUMNS,
        true,
      );
    },
  },
  "delete rover": {
    usage: "delete rover <id>",
    run: async (args) => {
      const [id] = requireArgs(args, ["id"], "delete rover <id>");
      return callAndMessage("rover", "delete_vehiculo", { id });
    },
  },
  "event rover": {
    usage: "event rover",
    run: async () => callAndTable("rover", "get_evento_random", {}, EVENTO_COLUMNS, true),
  },
  "load rover": {
    usage: "load rover",
    run: async () => callAndMessage("rover", "load_eventos_db", {}),
  },

  "list inventario": {
    usage: "list inventario",
    run: async () => callAndTable("inventario", "get_items", {}, INVENTARIO_COLUMNS),
  },
  "create inventario": {
    usage: 'create inventario <name> <description> <cantidad> <prioridad>',
    run: async (args) => {
      const [name, description, cantidad, prioridad] = requireArgs(
        args,
        ["name", "description", "cantidad", "prioridad"],
        'create inventario <name> <description> <cantidad> <prioridad>',
      );
      return callAndTable(
        "inventario",
        "create_item",
        {
          name,
          description,
          cantidad: num(cantidad, "cantidad"),
          prioridad: num(prioridad, "prioridad"),
        },
        INVENTARIO_COLUMNS,
        true,
      );
    },
  },
  "update inventario": {
    usage: 'update inventario <id> <name> <description> <cantidad> <prioridad>',
    run: async (args) => {
      const [id, name, description, cantidad, prioridad] = requireArgs(
        args,
        ["id", "name", "description", "cantidad", "prioridad"],
        'update inventario <id> <name> <description> <cantidad> <prioridad>',
      );
      return callAndTable(
        "inventario",
        "update_item",
        {
          id,
          name,
          description,
          cantidad: num(cantidad, "cantidad"),
          prioridad: num(prioridad, "prioridad"),
        },
        INVENTARIO_COLUMNS,
        true,
      );
    },
  },
  "delete inventario": {
    usage: "delete inventario <id>",
    run: async (args) => {
      const [id] = requireArgs(args, ["id"], "delete inventario <id>");
      return callAndMessage("inventario", "delete_item", { id });
    },
  },

  "list central": {
    usage: "list central",
    run: async () => callAndTable("central", "read_all_events", {}, CENTRAL_COLUMNS),
  },
  "create central": {
    usage: 'create central <name> <description> <pos_x> <pos_y>',
    run: async (args) => {
      const [name, description, posX, posY] = requireArgs(
        args,
        ["name", "description", "pos_x", "pos_y"],
        'create central <name> <description> <pos_x> <pos_y>',
      );
      return callAndTable(
        "central",
        "recibir_evento",
        { name, description, pos_x: num(posX, "pos_x"), pos_y: num(posY, "pos_y") },
        CENTRAL_COLUMNS,
        true,
      );
    },
  },
  "update central": {
    usage: 'update central <id> <name> <description> <pos_x> <pos_y>',
    run: async (args) => {
      const [id, name, description, posX, posY] = requireArgs(
        args,
        ["id", "name", "description", "pos_x", "pos_y"],
        'update central <id> <name> <description> <pos_x> <pos_y>',
      );
      return callAndTable(
        "central",
        "update_event",
        { id, name, description, pos_x: num(posX, "pos_x"), pos_y: num(posY, "pos_y") },
        CENTRAL_COLUMNS,
        true,
      );
    },
  },
  "delete central": {
    usage: "delete central <id>",
    run: async (args) => {
      const [id] = requireArgs(args, ["id"], "delete central <id>");
      return callAndMessage("central", "delete_event", { id });
    },
  },
};

function helpBlocks(): OutputBlock[] {
  const groups: Array<[string, string[]]> = [
    [
      "rover",
      [
        "list rover",
        "get rover",
        "create rover",
        "move rover",
        "delete rover",
        "event rover",
        "load rover",
      ],
    ],
    ["inventario", ["list inventario", "create inventario", "update inventario", "delete inventario"]],
    ["central", ["list central", "create central", "update central", "delete central"]],
  ];

  const lines: OutputBlock[] = [
    { kind: "line", tone: "info", text: "comandos disponibles:" },
  ];
  for (const [group, keys] of groups) {
    lines.push({ kind: "line", text: `  ${group}:` });
    for (const key of keys) {
      lines.push({ kind: "line", text: `    ${COMMANDS[key].usage}` });
    }
  }
  lines.push({ kind: "line", text: "  clear" }, { kind: "line", text: "  help" });
  lines.push({
    kind: "line",
    tone: "info",
    text: 'usa comillas para argumentos con espacios, ej: create inventario "Panel solar" "Repuesto" 10 3',
  });
  return lines;
}

export async function execute(line: string): Promise<OutputBlock[]> {
  const tokens = tokenize(line.trim());
  if (tokens.length === 0) return [];

  const verb = tokens[0].toLowerCase();
  if (verb === "help") return helpBlocks();

  const resource = tokens[1]?.toLowerCase();
  const key = resource ? `${verb} ${resource}` : verb;
  const spec = COMMANDS[key];
  if (!spec) {
    return [
      {
        kind: "line",
        tone: "error",
        text: `comando no reconocido: "${line}". Escribe "help" para ver los comandos disponibles.`,
      },
    ];
  }

  try {
    return await spec.run(tokens.slice(2));
  } catch (e) {
    if (e instanceof CommandError) {
      return [{ kind: "line", tone: "error", text: e.message }];
    }
    return [{ kind: "line", tone: "error", text: e instanceof Error ? e.message : String(e) }];
  }
}

export function formatTable(columns: string[], rows: Array<Array<string | number>>): string {
  const widths = columns.map((col, i) =>
    Math.max(col.length, ...rows.map((r) => String(r[i] ?? "").length)),
  );
  const line = (cells: Array<string | number>) =>
    cells.map((c, i) => String(c ?? "").padEnd(widths[i])).join("  ");
  const separator = widths.map((w) => "-".repeat(w)).join("  ");
  return [line(columns), separator, ...rows.map(line)].join("\n");
}
