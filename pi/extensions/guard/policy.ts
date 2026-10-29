import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

/** Las reglas de riesgo viven en guard-bash.sh: esta capa sólo decide qué evaluar con él. */
const GUARD = fileURLToPath(new URL("./guard-bash.sh", import.meta.url));

type Input = Record<string, unknown>;
type Check = (input: Input) => string | undefined;

/** Herramientas de Pi que se evalúan, por nombre. El resto pasa sin chequeo. */
const PI_CHECKS: Record<string, Check> = {
  bash: (input) => guardCommand(text(input.command)),
  read: (input) => guardRead(text(input.path)),
};

/** Motivo del bloqueo de una herramienta de Pi, o undefined si puede correr. */
export function checkPiTool(toolName: string, input: Input): string | undefined {
  return PI_CHECKS[toolName]?.(input);
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

function text(value: unknown): string {
  return typeof value === "string" ? value : "";
}
