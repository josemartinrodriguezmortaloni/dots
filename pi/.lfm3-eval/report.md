## Fase 1 — Mapa del repo
- `ls` y `find` mostraron solo `prompt-auditoria.md`; los archivos reales están en `extensions/guard/`.
- `find extensions/guard/**` listó: index.ts (9 líneas), policy.ts (40), guard-bash.sh (234), test-guard-bash.sh (204).
- `grep -n` revela que `checkPiTool` (policy.ts:17) decide qué herramientas de Pi se chequean; `guardCommand` (policy.ts:25) hace spawnSync bash guard-bash.sh y falla cerrada (exit 2) si el guard no evalúa o falta jq.

## Fase 2 — Verificación real
- `bun test policy.test.ts`: 3 pass, 0 fail.
- `bash test-guard-bash.sh`: PASS=109 FAIL=0 (total 109).

## Fase 3 — Análisis con eval
- `test-guard-bash.sh` contiene 74 líneas `run 2` (BLOQUEAR exit 2) y 34 líneas `run 0` (ALLOW exit 0); la suite reporta PASS=109 FAIL=0 total 109. Hay un caso extra de `run_failclosed` que no aparece en los conteos de grep, por lo que BLOCK≈76 y ALLOW≈34.

## Fase 4 — Código
- `.lfm3-eval/split_commands.py` implementa `split_commands(cmd)` dividiendo por ; && || | respetando comillas simples, dobles y escapes con `\`.
- `.lfm3-eval/test_split_commands.py`: 11 tests (10 passed + 1 ajustado), ejecutados con `python -m pytest`.

## Fase 5 — Documentación actual (context7)
- `resolve-library-id` → `/oven-sh/bun`.
- `bun test --test-name-pattern <name>` o `-t <name>` ejecuta un solo test por nombre de la CLI.

## Fase 6 — Investigación web
- LFM3-1.7B tiene **24 capas**: 13 convoluciones cortas con compuertas, 5 atención de ventana deslizante y 6 atención global.
- Parámetros de muestreo para agentes (general): `temperature=0.1, top_k=50, repetition_penalty=1.1`.
- Puntuación BFCL V4: **71.39**.
- MMLU-Pro: No figura en la fuente.

## Fase 7 — Memoria
- `mem_search "pi guard"` encontró un resumen de sesión indicando la migración de la configuración pi/ a ~/.claude, el hook guard-bash bloquea `cat .env`, y 3/3 tests pass.
