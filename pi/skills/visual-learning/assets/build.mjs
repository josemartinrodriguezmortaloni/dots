#!/usr/bin/env node
// Assembles <dir>/parts into one self-contained <dir>/index.html, after the gate passes.
// Usage: node build.mjs <dir> --lang es --title "Title"

import { existsSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { dirname, extname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { parseArgs } from "node:util";
import { Script } from "node:vm";

const HERE = dirname(fileURLToPath(import.meta.url));
const MATHJAX = "https://cdn.jsdelivr.net/npm/mathjax@4/tex-mml-chtml.js";
const MIME = {
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".gif": "image/gif",
  ".webp": "image/webp",
  ".svg": "image/svg+xml",
};
const FIGURE_SRC = /src="(figures\/[^"]+)"/g;

const { values: options, positionals } = parseArgs({
  allowPositionals: true,
  options: {
    lang: { type: "string", default: "es" },
    title: { type: "string", default: "Textbook" },
  },
});
const dir = positionals[0];

// Parts

function readParts(sub, ext) {
  const path = join(dir, "parts", sub);
  if (!existsSync(path)) return [];
  return readdirSync(path)
    .filter((file) => file.endsWith(ext))
    .sort()
    .map((file) => ({ file, text: readFileSync(join(path, file), "utf8") }));
}

const joinText = (parts) => parts.map((part) => part.text).join("\n");

// Gate

const ids = (text, pattern) => new Set([...text.matchAll(pattern)].map((match) => match[1]));
const missing = (used, defined) => [...used].filter((id) => !defined.has(id));

function syntaxError({ file, text }) {
  try {
    new Script(text, { filename: file });
    return [];
  } catch (err) {
    return [`widget syntax: ${file}: ${err.message}`];
  }
}

function gate({ sections, concepts, widgets }) {
  const content = sections + concepts;
  const widgetCode = joinText(widgets);
  return [
    ...(sections ? [] : ["no section in parts/sections"]),
    ...missing(ids(content, /data-c="([^"]+)"/g), ids(concepts, /data-concept="([^"]+)"/g)).map((id) => `concept without record: ${id}`),
    ...missing(ids(content, /data-widget="([^"]+)"/g), ids(widgetCode, /W\["([^"]+)"\]/g)).map((id) => `widget without code: ${id}`),
    ...[...ids(content, FIGURE_SRC)].filter((path) => !existsSync(join(dir, path))).map((path) => `figure not found: ${path}`),
    ...widgets.flatMap(syntaxError),
  ];
}

// Page

const ESCAPES = { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" };
const escapeHtml = (text) => text.replace(/[&<>"]/g, (char) => ESCAPES[char]);

function dataUri(path) {
  const mime = MIME[extname(path).toLowerCase()] ?? "application/octet-stream";
  return `data:${mime};base64,${readFileSync(join(dir, path)).toString("base64")}`;
}

const inlineFigures = (html) => html.replace(FIGURE_SRC, (_, path) => `src="${dataUri(path)}"`);

const page = ({ sections, concepts, widgets }) => `<!doctype html>
<html lang="${escapeHtml(options.lang)}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${escapeHtml(options.title)}</title>
<style>
${readFileSync(join(HERE, "page.css"), "utf8")}
</style>
<script>window.W = {};</script>
<script defer src="${MATHJAX}"></script>
</head>
<body>
<main>
<h1>${escapeHtml(options.title)}</h1>
${sections}
</main>
${concepts}
${widgets.map(({ text }) => `<script>\n${text}\n</script>`).join("\n")}
<script>
${readFileSync(join(HERE, "runtime.js"), "utf8")}
</script>
</body>
</html>
`;

// Main

function build() {
  const parts = {
    sections: joinText(readParts("sections", ".html")),
    concepts: joinText(readParts("concepts", ".html")),
    widgets: readParts("widgets", ".js"),
  };
  const errors = gate(parts);
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  const out = join(dir, "index.html");
  writeFileSync(out, inlineFigures(page(parts)));
  console.log(`OK ${out}`);
}

if (!dir) {
  console.error('Usage: node build.mjs <dir> --lang es --title "Title"');
  process.exit(2);
}
build();
