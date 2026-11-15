const HIDDEN_BLOCKS = /<(script|style|title|head)\b[^>]*>[\s\S]*?<\/\1>/giu;
const TAGS = /<[^>]*>/gu;
const ENTITIES: Readonly<Record<string, string>> = { "&nbsp;": " ", "&amp;": "&", "&lt;": "<", "&gt;": ">", "&quot;": "\"", "&#39;": "'" };

export function visibleTextOf(html: string): string {
  return html
    .replace(HIDDEN_BLOCKS, " ")
    .replace(TAGS, " ")
    .replace(/&[#a-z0-9]+;/giu, (entity) => ENTITIES[entity] ?? entity)
    .replace(/\s+/gu, " ")
    .trim();
}
