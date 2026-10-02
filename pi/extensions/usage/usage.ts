/** Límites de la suscripción de Claude según `api.anthropic.com/api/oauth/usage`. */
export interface Window {
  pct: number;
  resetsAt: Date | undefined;
}

export interface Extra {
  pct: number;
  usedUsd: number;
  limitUsd: number;
}

export interface Usage {
  fiveHour: Window | undefined;
  sevenDay: Window | undefined;
  extra: Extra | undefined;
}

export type Tone = "success" | "warning" | "error" | "dim" | "text";
export type Paint = (tone: Tone, text: string) => string;

const BAR_WIDTH = 8;
const SEP = "│";

type Json = Record<string, unknown>;

export function parseUsage(body: unknown): Usage {
  const json = Object(body) as Json;
  return {
    fiveHour: parseWindow(json.five_hour),
    sevenDay: parseWindow(json.seven_day),
    extra: parseExtra(json.extra_usage),
  };
}

/** Segmentos del status: 5h, 7d, extra y duración de la sesión, en ese orden. */
export function formatStatus(usage: Usage | undefined, elapsedMs: number, paint: Paint): string {
  const segments = [
    windowSegment("5h", usage?.fiveHour, formatTime, paint),
    windowSegment("7d", usage?.sevenDay, formatDateTime, paint),
    extraSegment(usage?.extra, paint),
    `${paint("dim", "⏱")} ${duration(elapsedMs)}`,
  ];
  return segments.filter(Boolean).join(` ${paint("dim", SEP)} `);
}

export function toneFor(pct: number): Tone {
  if (pct >= 90) return "error";
  return pct >= 50 ? "warning" : "success";
}

export function bar(pct: number, paint: Paint): string {
  const filled = Math.round((clamp(pct) * BAR_WIDTH) / 100);
  return paint(toneFor(pct), "●".repeat(filled)) + paint("dim", "○".repeat(BAR_WIDTH - filled));
}

export function duration(ms: number): string {
  const minutes = Math.floor(ms / 60_000);
  if (minutes >= 60) return `${Math.floor(minutes / 60)}h${minutes % 60}m`;
  return minutes >= 1 ? `${minutes}m` : `${Math.floor(ms / 1000)}s`;
}

function windowSegment(label: string, window: Window | undefined, when: (d: Date) => string, paint: Paint) {
  if (!window) return "";
  const reset = window.resetsAt ? ` ${paint("dim", `⟳ ${when(window.resetsAt)}`)}` : "";
  return `${paint("text", label)} ${bar(window.pct, paint)} ${paint(toneFor(window.pct), `${window.pct}%`)}${reset}`;
}

function extraSegment(extra: Extra | undefined, paint: Paint): string {
  if (!extra) return "";
  const spent = `$${extra.usedUsd.toFixed(2)}/$${extra.limitUsd.toFixed(2)}`;
  return `${paint("text", "extra")} ${bar(extra.pct, paint)} ${paint(toneFor(extra.pct), spent)}`;
}

function parseWindow(value: unknown): Window | undefined {
  const json = Object(value) as Json;
  if (typeof json.utilization !== "number") return undefined;
  return { pct: Math.round(json.utilization), resetsAt: parseDate(json.resets_at) };
}

/** La API informa créditos en centavos. */
function parseExtra(value: unknown): Extra | undefined {
  const json = Object(value) as Json;
  if (json.is_enabled !== true) return undefined;
  return {
    pct: Math.round(number(json.utilization)),
    usedUsd: number(json.used_credits) / 100,
    limitUsd: number(json.monthly_limit) / 100,
  };
}

function parseDate(value: unknown): Date | undefined {
  if (typeof value !== "string") return undefined;
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? undefined : date;
}

function number(value: unknown): number {
  return typeof value === "number" ? value : 0;
}

function formatTime(date: Date): string {
  return date.toLocaleTimeString("es-AR", { hour: "2-digit", minute: "2-digit", hour12: false });
}

function formatDateTime(date: Date): string {
  return date.toLocaleString("es-AR", { day: "numeric", month: "short", hour: "2-digit", minute: "2-digit", hour12: false });
}

function clamp(pct: number): number {
  return Math.min(100, Math.max(0, pct));
}
