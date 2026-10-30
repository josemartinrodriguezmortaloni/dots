import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { neutralizeResult, restoreInput } from "./tokens.ts";

export default function (pi: ExtensionAPI) {
  pi.on("tool_result", (event) => neutralizeResult(event));
  pi.on("tool_call", (event) => restoreInput(Object(event.input)));
}
