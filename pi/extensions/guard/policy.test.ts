import assert from "node:assert/strict";
import { test } from "node:test";
import { allowsCommand, checkPiTool, voteClaudeTool } from "./policy.ts";

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

test("claude: deny gana sobre un prefijo permitido", () => {
  assert.equal(voteClaudeTool("Bash", { command: "cp .env /tmp/x" }), "deny");
  assert.equal(voteClaudeTool("Bash", { command: "git push --force" }), "deny");
  assert.equal(voteClaudeTool("Read", { file_path: "/repo/secrets/token" }), "deny");
});

test("claude: allow sólo si cada segmento coincide con un prefijo", () => {
  assert.equal(voteClaudeTool("Bash", { command: "git status && cargo test" }), "allow");
  assert.equal(voteClaudeTool("Bash", { command: "ls && curl example.com" }), "ask");
  assert.equal(voteClaudeTool("Bash", { command: "gitk" }), "ask");
});

test("claude: mcp de engram y context7 pasan, el resto pregunta", () => {
  assert.equal(voteClaudeTool("mcp__pi__mem_save", {}), "allow");
  assert.equal(voteClaudeTool("mcp__engram__mem_search", {}), "allow");
  assert.equal(voteClaudeTool("mcp__pi__query-docs", {}), "allow");
  assert.equal(voteClaudeTool("mcp__pi__linear_delete_issue", {}), "ask");
  assert.equal(voteClaudeTool("Read", { file_path: "/repo/README.md" }), "ask");
});

test("allowsCommand: sustituciones, redirecciones y vacíos van al diálogo", () => {
  assert.equal(allowsCommand("ls $(rm -rf /tmp/x)"), false);
  assert.equal(allowsCommand("ls > out.txt"), false);
  assert.equal(allowsCommand("ls `whoami`"), false);
  assert.equal(allowsCommand("ls;"), false);
  assert.equal(allowsCommand("   "), false);
});
