import { readFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { formatStatus, parseUsage, type Paint, type Usage } from "./usage.ts";

/**
 * Límites 5h/7d/extra de la suscripción de Claude y duración de la sesión, en la línea de
 * estados del footer de Pi. El resto de la vieja statusline (modelo, rama, contexto, thinking)
 * ya lo muestra el footer por defecto.
 */
const STATUS_KEY = "usage";
const REFRESH_MS = 60_000;
const USAGE_URL = "https://api.anthropic.com/api/oauth/usage";
/** El login del binario `claude` que usa pi-claude-acp. El token sólo viaja a api.anthropic.com. */
const CREDENTIALS = join(homedir(), ".claude", ".credentials.json");

export default function (pi: ExtensionAPI) {
  let timer: NodeJS.Timeout | undefined;
  let usage: Usage | undefined;
  const startedAt = Date.now();

  const refresh = async (ctx: ExtensionContext) => {
    usage = (await fetchUsage()) ?? usage;
    ctx.ui.setStatus(STATUS_KEY, formatStatus(usage, Date.now() - startedAt, painter(ctx)));
  };

  pi.on("session_start", async (_event, ctx) => {
    clearInterval(timer);
    timer = setInterval(() => void refresh(ctx), REFRESH_MS);
    await refresh(ctx);
  });

  pi.on("session_shutdown", () => {
    clearInterval(timer);
    timer = undefined;
  });
}

function painter(ctx: ExtensionContext): Paint {
  return (tone, text) => ctx.ui.theme.fg(tone, text);
}

/** Un fallo de red o de login deja el último valor conocido: el status nunca rompe la sesión. */
async function fetchUsage(): Promise<Usage | undefined> {
  try {
    const token = await accessToken();
    const response = await fetch(USAGE_URL, { headers: headers(token), signal: AbortSignal.timeout(5000) });
    return response.ok ? parseUsage(await response.json()) : undefined;
  } catch {
    return undefined;
  }
}

async function accessToken(): Promise<string> {
  const credentials = JSON.parse(await readFile(CREDENTIALS, "utf8"));
  return String(credentials.claudeAiOauth.accessToken);
}

function headers(token: string): Record<string, string> {
  return {
    Accept: "application/json",
    Authorization: `Bearer ${token}`,
    "anthropic-beta": "oauth-2025-04-20",
  };
}
