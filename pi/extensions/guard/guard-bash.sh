#!/usr/bin/env bash
# guard-bash.sh — Reglas de riesgo para comandos de shell. Lo invoca la extensión
# guard de Pi (policy.ts) para su herramienta bash, su herramienta read y las de Claude Code.
#
# Lee por stdin el JSON del evento, extrae .tool_input.command y lo evalúa contra
# clases de comandos peligrosos. Si detecta riesgo, sale con código 2 (BLOQUEA y
# manda el motivo por stderr al modelo). Si no, sale 0 (permite).
#
# Principios de diseño:
#   - FAIL-CLOSED: si no puede evaluar (falta jq), bloquea. Un control de
#     seguridad que falla ABIERTO es peor que no tener control.
#   - Detección por VERBO de comando, no por "menciona el string": evita falsos
#     positivos como `git commit -m "edita el .env"`.
#   - Evaluación por SEGMENTOS (corta en && || | ; &): atrapa el comando peligroso
#     escondido en un compuesto (`ls && rm -rf .`).
#   - Única dependencia externa: jq. El resto son builtins de bash.
#
# Contrato (el de los hooks PreToolUse de Claude Code): exit 2 => deny + motivo
# por stderr. exit 0 => allow.

set -uo pipefail

# ───────────────────────── helpers ─────────────────────────

# Quita UNA capa de comillas envolventes de un token.
strip_q() {
  local t="$1"
  t="${t#\"}"; t="${t%\"}"
  t="${t#\'}"; t="${t%\'}"
  printf '%s' "$t"
}

# Elimina el CONTENIDO de comillas (para chequeos estructurales de git: así un
# mensaje de commit con palabras peligrosas no genera falso positivo).
strip_quotes() {
  local s="$1" out="" i c q="" n
  n=${#s}
  for ((i = 0; i < n; i++)); do
    c="${s:i:1}"
    if [ -n "$q" ]; then
      [ "$c" = "$q" ] && q=""
      continue
    fi
    if [ "$c" = '"' ] || [ "$c" = "'" ]; then q="$c"; continue; fi
    out+="$c"
  done
  printf '%s' "$out"
}

# ¿El token es un objetivo catastrófico para un borrado recursivo?
is_danger_target() {
  local t; t="$(strip_q "$1")"
  case "$t" in
    "/"|'/*'|"~"|"~/"|'~/*'|'$HOME'|'${HOME}'|'$HOME/'|'${HOME}/'|'$HOME/*'|'${HOME}/*'|"."|"./"|'./*'|".."|"../"|'../*'|"*")
      return 0 ;;
  esac
  # rutas absolutas de sistema
  [[ "$t" =~ ^/(bin|boot|dev|etc|home|lib|lib32|lib64|libx32|media|mnt|opt|proc|root|run|sbin|srv|sys|usr|var)(/.*)?$ ]] && return 0
  return 1
}

# ¿El token apunta a un archivo sensible (secreto/credencial/clave)?
is_sensitive() {
  local t; t="$(strip_q "$1")"
  t="${t##*@}"   # curl -d @.env  -> .env
  t="${t##*=}"   # -F file=@.env  -> .env
  # excluir templates públicos
  [[ "$t" =~ \.env\.(example|sample|template|dist|defaults?) ]] && return 1
  case "$t" in *.env.example|*.env.sample|*.env.template) return 1;; esac
  # .env y variantes reales
  [[ "$t" =~ (^|/)\.env($|\.|:) ]] && return 0
  case "$t" in
    .env|*/.env|*.env.local|*.env.production|*.env.*) return 0;;
  esac
  # credenciales / claves
  case "$t" in
    *credentials*|*secrets/*|secrets/*|*.pem|*.netrc|*.npmrc|*.git-credentials|*.pgpass|*.htpasswd) return 0;;
    *.ssh/*) return 0;;
  esac
  [[ "$t" =~ (^|/)id_(rsa|dsa|ecdsa|ed25519)($|\.) ]] && return 0
  return 1
}

# Devuelve el índice del verbo real saltando prefijos (sudo, env, VAR=val…).
verb_index() {
  local -n _t="$1"; local i=0
  while [ $i -lt ${#_t[@]} ]; do
    local tok; tok="$(strip_q "${_t[i]}")"; tok="${tok#\\}"
    case "$tok" in
      sudo|command|env|time|nice|nohup|xargs|builtin|exec) i=$((i + 1));;
      *=*) i=$((i + 1));;
      *) break;;
    esac
  done
  printf '%s' "$i"
}

# ───────────────────────── chequeos ─────────────────────────

# Borrado destructivo
check_rm() {
  local seg="$1"; local -a toks; read -ra toks <<< "$seg"
  [ ${#toks[@]} -gt 0 ] || return 1
  local i; i="$(verb_index toks)"
  local verb; verb="$(strip_q "${toks[i]:-}")"; verb="${verb#\\}"; verb="${verb##*/}"
  [ "$verb" = "rm" ] || return 1

  local recursive=1 noproot=1 j
  local -a targets=()
  for ((j = i + 1; j < ${#toks[@]}; j++)); do
    local tk; tk="$(strip_q "${toks[j]}")"
    if [ "$tk" = "--no-preserve-root" ]; then noproot=0; continue; fi
    if [[ "$tk" =~ ^-[a-zA-Z]*[rR][a-zA-Z]*$ ]] || [ "$tk" = "--recursive" ]; then recursive=0; continue; fi
    [[ "$tk" == -* ]] && continue
    targets+=("$tk")
  done

  [ $noproot -eq 0 ] && { REASON="rm --no-preserve-root (borrado catastrófico de la raíz)"; return 0; }
  [ $recursive -eq 0 ] || return 1
  local t
  for t in "${targets[@]}"; do
    if is_danger_target "$t"; then
      REASON="rm recursivo sobre objetivo peligroso: '$t'"; return 0
    fi
  done
  return 1
}

# Lectura / exfiltración de secretos
check_secrets() {
  local seg="$1"; local -a toks; read -ra toks <<< "$seg"
  [ ${#toks[@]} -gt 0 ] || return 1
  local i; i="$(verb_index toks)"
  local verb; verb="$(strip_q "${toks[i]:-}")"; verb="${verb#\\}"; verb="${verb##*/}"

  local -a args=(); local j
  for ((j = i + 1; j < ${#toks[@]}; j++)); do args+=("$(strip_q "${toks[j]}")"); done

  case "$verb" in
    cat|bat|tac|nl|head|tail|less|more|most|view|rg|grep|egrep|fgrep|ag|ack|strings|xxd|hexdump|od|sort|uniq|awk|sed|cut|base64|tee)
      local a; for a in "${args[@]}"; do
        is_sensitive "$a" && { REASON="lectura de secreto vía $verb: '$a'"; return 0; }
      done ;;
    cp|mv|install|rsync|scp|ln)
      local -a files=(); local a
      for a in "${args[@]}"; do [[ "$a" == -* ]] && continue; files+=("$a"); done
      local fn=${#files[@]} k
      for ((k = 0; k < fn - 1; k++)); do
        is_sensitive "${files[k]}" && { REASON="exfiltración de secreto vía $verb (origen): '${files[k]}'"; return 0; }
      done ;;
    curl|wget|tar|zip|7z|7za|gzip|bzip2|xz|gpg|dd|openssl)
      local a; for a in "${args[@]}"; do
        is_sensitive "$a" && { REASON="acceso/exfiltración de secreto vía $verb: '$a'"; return 0; }
      done ;;
  esac
  return 1
}

# Git destructivo
check_git() {
  local seg; seg="$(strip_quotes "$1")"
  [[ "$seg" =~ (^|[[:space:]/])git([[:space:]]|$) ]] || return 1

  if [[ "$seg" =~ git[[:space:]].*reset([[:space:]]|$) ]] && [[ "$seg" =~ reset[[:space:]].*--hard ]]; then
    REASON="git reset --hard (descarta el working tree sin aviso)"; return 0
  fi

  if [[ "$seg" =~ checkout([[:space:]]|$) ]]; then
    if [[ "$seg" =~ checkout([[:space:]]+[^[:space:]]+)*[[:space:]]+--([[:space:]]|$) ]] \
      || [[ "$seg" =~ checkout[[:space:]]+(-f|--force)([[:space:]]|$) ]] \
      || [[ "$seg" =~ checkout([[:space:]]+-[^[:space:]]+)*[[:space:]]+\.($|[[:space:]]) ]] \
      || [[ "$seg" =~ checkout[[:space:]]+\.($|[[:space:]]) ]] \
      || [[ "$seg" =~ checkout[[:space:]]+\*($|[[:space:]]) ]]; then
      REASON="git checkout destructivo (descarta cambios sin commit)"; return 0
    fi
  fi

  if [[ "$seg" =~ clean([[:space:]]|$) ]] && [[ "$seg" =~ clean[[:space:]]+(-[a-zA-Z]*f|--force) ]]; then
    REASON="git clean forzado (borra archivos untracked)"; return 0
  fi

  if [[ "$seg" =~ push([[:space:]]|$) ]]; then
    if [[ "$seg" =~ --force-with-lease ]]; then
      :
    elif [[ "$seg" =~ --force([[:space:]]|$) ]]; then
      REASON="git push --force (reescribe historia remota)"; return 0
    elif [[ "$seg" =~ (^|[[:space:]])-f([[:space:]]|$) ]]; then
      REASON="git push -f (reescribe historia remota)"; return 0
    elif [[ "$seg" =~ push[[:space:]].*[[:space:]]\+[^[:space:]+] ]]; then
      REASON="git push con refspec forzado '+' (reescribe historia remota)"; return 0
    fi
  fi
  return 1
}

block() {
  {
    echo "🛑 guard-bash BLOQUEÓ un comando de riesgo."
    echo "   Motivo: $1"
    echo "   Comando: $cmd"
    echo "   Si es intencional, ejecutalo vos mismo en tu terminal."
  } >&2
  exit 2
}

# ───────────────────────── main ─────────────────────────

input="$(cat)"

if ! command -v jq >/dev/null 2>&1; then
  echo "🛑 guard-bash: 'jq' no disponible — bloqueo por seguridad (fail-closed). Instalá jq." >&2
  exit 2
fi

cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -z "$cmd" ] && exit 0

# Normalizar separadores de shell a saltos de línea para evaluar por segmentos.
norm="$cmd"
norm="${norm//&&/$'\n'}"
norm="${norm//||/$'\n'}"
norm="${norm//|/$'\n'}"
norm="${norm//;/$'\n'}"
norm="${norm//&/$'\n'}"

REASON=""
while IFS= read -r seg; do
  [ -z "${seg// /}" ] && continue
  if check_rm "$seg" || check_secrets "$seg" || check_git "$seg"; then
    block "$REASON"
  fi
done <<< "$norm"

exit 0
