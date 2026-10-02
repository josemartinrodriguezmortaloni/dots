. "$HOME/.cargo/env"

# Claude Code sin estado propio: Engram es la única memoria y los MCP los
# provee Pi. settings.json no aplica dentro de Pi (settingSources: []), así
# que estas variables son el único interruptor que cubre la terminal y Pi.
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=1
export ENABLE_CLAUDEAI_MCP_SERVERS=false
