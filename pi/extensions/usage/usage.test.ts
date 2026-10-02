import assert from "node:assert/strict";
import { test } from "node:test";
import { bar, duration, formatStatus, parseUsage, toneFor, type Paint } from "./usage.ts";

const plain: Paint = (_tone, text) => text;

const BODY = {
  five_hour: { utilization: 42.4, resets_at: "2026-10-02T18:00:00Z" },
  seven_day: { utilization: 91, resets_at: "2026-10-05T12:00:00Z" },
  extra_usage: { is_enabled: true, utilization: 10, used_credits: 1250, monthly_limit: 5000 },
};

test("parseUsage: lee ventanas, redondea y pasa créditos de centavos a dólares", () => {
  const usage = parseUsage(BODY);
  assert.equal(usage.fiveHour?.pct, 42);
  assert.equal(usage.sevenDay?.resetsAt?.toISOString(), "2026-10-05T12:00:00.000Z");
  assert.deepEqual(usage.extra, { pct: 10, usedUsd: 12.5, limitUsd: 50 });
});

test("parseUsage: extra deshabilitado y cuerpos inválidos no producen segmentos", () => {
  const usage = parseUsage({ extra_usage: { is_enabled: false }, five_hour: { utilization: "x" } });
  assert.deepEqual(usage, { fiveHour: undefined, sevenDay: undefined, extra: undefined });
  assert.deepEqual(parseUsage(null), usage);
});

test("formatStatus: sin datos de uso queda sólo la duración", () => {
  assert.equal(formatStatus(undefined, 90_000, plain), "⏱ 1m");
});

test("formatStatus: ordena 5h, 7d, extra y duración", () => {
  const status = formatStatus(parseUsage(BODY), 3_720_000, plain);
  assert.match(status, /^5h ●●●○○○○○ 42% ⟳ .+ │ 7d ●●●●●●●○ 91% ⟳ .+ │ extra ●○○○○○○○ \$12\.50\/\$50\.00 │ ⏱ 1h2m$/);
});

test("toneFor y bar: umbrales 50/90 y barra acotada a 0-100", () => {
  assert.deepEqual([toneFor(49), toneFor(50), toneFor(90)], ["success", "warning", "error"]);
  assert.equal(bar(150, plain), "●●●●●●●●");
  assert.equal(bar(-5, plain), "○○○○○○○○");
});

test("duration: segundos, minutos y horas", () => {
  assert.deepEqual([duration(5_000), duration(120_000), duration(7_260_000)], ["5s", "2m", "2h1m"]);
});
