import type { Slot } from "../catalog/catalog_types.ts";
import { BRAND_APP_ICON_SVG } from "./brand.generated.ts";
import { htmlDocument, type Composition } from "./composition.ts";

const XML_DECLARATION = /^<\?xml[^>]*\?>\s*/u;

export function buildAppIcon(id: string, slot: Slot): Composition {
  const canvas = { width: slot.width, height: slot.height };
  const icon = BRAND_APP_ICON_SVG.replace(XML_DECLARATION, "")
    .replace("<svg ", `<svg width="${canvas.width}" height="${canvas.height}" `);
  const html = htmlDocument({ id, canvas, durationSeconds: 1, style: "", body: icon, timeline: "" });
  const elements = [{ name: "icon", rect: { x: 0, y: 0, ...canvas }, essential: true, content: "artwork" as const }];
  return { id, canvas, durationSeconds: 1, html, layout: [{ timeSeconds: 0, elements }], texts: [] };
}
