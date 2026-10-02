import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { checkPiTool, voteClaudeTool, type Vote } from "./policy.ts";

/**
 * Canal donde pi-claude-acp pide un voto por cada herramienta de Claude Code
 * (pi-claude-acp/src/permissions.ts). Esas herramientas corren dentro de Claude Code
 * y nunca pasan por el evento `tool_call` de Pi.
 */
const TOOL_REQUEST_EVENT = "claude-acp:tool-request";

interface ToolRequest {
  toolCall: { rawInput?: unknown; _meta?: unknown };
  vote(decision: Promise<Vote>): void;
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", (event) => {
    const reason = checkPiTool(event.toolName, Object(event.input));
    return reason ? { block: true, reason } : undefined;
  });

  pi.events.on(TOOL_REQUEST_EVENT, (data) => {
    const { toolCall, vote } = data as ToolRequest;
    vote(Promise.resolve(voteClaudeTool(claudeToolName(toolCall), Object(toolCall.rawInput))));
  });
}

function claudeToolName(toolCall: ToolRequest["toolCall"]): string {
  const meta = Object(Object(toolCall._meta).claudeCode) as { toolName?: unknown };
  return typeof meta.toolName === "string" ? meta.toolName : "";
}
