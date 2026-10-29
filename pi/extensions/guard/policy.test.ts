import assert from "node:assert/strict";
import { test } from "node:test";
import { checkPiTool } from "./policy.ts";

/** El motivo como texto: `undefined` no coincide con ningún patrón de bloqueo. */
const reason = (toolName: string, input: Record<string, unknown>) => String(checkPiTool(toolName, input));

test("pi bash: bloquea lo que guard-bash.sh bloquea y deja pasar el resto", () => {
  assert.match(reason("bash", { command: "ls && rm -rf ~" }), /rm recursivo/);
  assert.equal(checkPiTool("bash", { command: "git status" }), undefined);
});

test("pi read: bloquea secretos y deja pasar templates públicos", () => {
  assert.match(reason("read", { path: "/repo/.env" }), /secreto/);
  assert.match(reason("read", { path: "/home/u/.ssh/id_ed25519" }), /secreto/);
  assert.equal(checkPiTool("read", { path: "/repo/.env.example" }), undefined);
  assert.equal(checkPiTool("read", { path: "/repo/src/main.rs" }), undefined);
});

test("pi: las herramientas sin chequeo pasan", () => {
  assert.equal(checkPiTool("edit", { path: "/repo/.env" }), undefined);
});
