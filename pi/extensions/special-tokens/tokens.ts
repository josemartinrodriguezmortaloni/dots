/**
 * Texto que llama.cpp convierte en tokens de control de LFM3 aunque llegue dentro de un resultado de
 * herramienta (lista: `added_tokens` de tokenizer.json). Una página con `<|im_start|>user` abre un
 * turno falso del usuario; `<tool_call>` abre una llamada falsa.
 */
const CONTROL =
  /<(?=\|[\w.-]+\|>|\/?(?:think|tool_call|tool_response|tools|additional_tools)>|(?:function|parameter)=|\/(?:function|parameter)>|image>)/g;

/** Un espacio de ancho cero tras `<` corta el token y deja el texto igual a la vista. */
const MARK = "<​";

type ToolResult = { content: unknown; structuredContent?: unknown };

export function neutralize(text: string): string {
  return text.replace(CONTROL, MARK);
}

/** Neutraliza content y structuredContent juntos: reemplazar solo content descarta el segundo. */
export function neutralizeResult({ content, structuredContent }: ToolResult): ToolResult {
  return JSON.parse(neutralize(JSON.stringify({ content, structuredContent })));
}

/** Quita las marcas que el modelo copió de un resultado a los argumentos de una herramienta. */
export function restoreInput(input: Record<string, unknown>): void {
  Object.assign(input, JSON.parse(JSON.stringify(input).replaceAll(MARK, "<")));
}
