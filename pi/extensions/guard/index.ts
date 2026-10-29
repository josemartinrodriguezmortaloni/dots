import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { checkPiTool } from "./policy.ts";

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", (event) => {
    const reason = checkPiTool(event.toolName, Object(event.input));
    return reason ? { block: true, reason } : undefined;
  });
}
