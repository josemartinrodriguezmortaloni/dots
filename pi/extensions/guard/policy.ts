import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

/** Las reglas de riesgo viven en guard-bash.sh: esta capa sólo decide qué evaluar con él. */
const GUARD = fileURLToPath(new URL("./guard-bash.sh", import.meta.url));

/** Comandos que corren sin diálogo, migrados de `permissions.allow` de Claude Code. */
const ALLOWED_COMMANDS = [
  "bat", "rg", "fd", "sd", "eza", "ls", "pwd", "which", "mkdir", "touch", "cp", "mv",
  "npm", "npx", "bun", "node", "python", "pip", "cargo", "go", "make",
  "git status", "git diff", "git log", "git branch", "git add", "git stash",
];

/** Herramientas MCP de engram y context7, tanto las de Claude Code como las que Pi expone. */
const ALLOWED_TOOLS = /^mcp__(engram|context7)__|^mcp__pi__(mem_|query-docs$|resolve-library-id$)/;

/** Sustituciones y redirecciones esconden un segundo comando o una escritura: van al diálogo. */
const SHELL_EXPANSION = /[`<>]|\$\(/;
const SEPARATORS = /&&|\|\||[|;&\n]/;

export type Vote = "allow" | "deny" | "ask";
type Input = Record<string, unknown>;
type Check = (input: Input) => string | undefined;

/** Herramientas de Pi que se evalúan, por nombre. El resto pasa sin chequeo. */
const PI_CHECKS: Record<string, Check> = {
  bash: (input) => guardCommand(text(input.command)),
  read: (input) => guardRead(text(input.path)),
};

/** Las mismas reglas para las herramientas propias de Claude Code bajo pi-claude-acp. */
const CLAUDE_CHECKS: Record<string, Check> = {
  Bash: (input) => guardCommand(text(input.command)),
  Read: (input) => guardRead(text(input.file_path)),
};

/** Motivo del bloqueo de una herramienta de Pi, o undefined si puede correr. */
export function checkPiTool(toolName: string, input: Input): string | undefined {
  return PI_CHECKS[toolName]?.(input);
}

/** Voto para pi-claude-acp: deny gana, allow saltea el diálogo y ask lo deja decidir al modo o al usuario. */
export function voteClaudeTool(toolName: string, input: Input): Vote {
  if (CLAUDE_CHECKS[toolName]?.(input)) return "deny";
  return isAllowed(toolName, input) ? "allow" : "ask";
}

/**
 * Contrato de hook de Claude Code: el JSON del evento entra por stdin, exit 2 bloquea con el motivo
 * en stderr. Cualquier salida distinta de 0, incluso un spawn fallido, bloquea (fail-closed).
 */
export function guardCommand(command: string): string | undefined {
  const run = spawnSync("bash", [GUARD], {
    input: JSON.stringify({ tool_input: { command } }),
    encoding: "utf8",
  });
  return run.status === 0 ? undefined : run.stderr?.trim() || "guard-bash falló (fail-closed)";
}

/** Una lectura se evalúa como `cat <ruta>`: así la lista de secretos de guard-bash.sh es la única. */
export function guardRead(path: string): string | undefined {
  return path ? guardCommand(`cat ${path}`) : undefined;
}

export function allowsCommand(command: string): boolean {
  if (command.trim() === "" || SHELL_EXPANSION.test(command)) return false;
  return command.split(SEPARATORS).every(allowsSegment);
}

function allowsSegment(segment: string): boolean {
  const words = segment.trim().split(/\s+/).join(" ");
  return ALLOWED_COMMANDS.some((prefix) => words === prefix || words.startsWith(`${prefix} `));
}

function isAllowed(toolName: string, input: Input): boolean {
  return toolName === "Bash" ? allowsCommand(text(input.command)) : ALLOWED_TOOLS.test(toolName);
}

function text(value: unknown): string {
  return typeof value === "string" ? value : "";
}
