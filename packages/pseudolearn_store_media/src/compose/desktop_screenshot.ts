import type { Slot } from "../catalog/catalog_types.ts";
import type { CodeBar, CodeBarRole } from "../layout/code_bars.ts";
import type { PixelRect } from "../layout/pixel_rect.ts";
import { WINDOW_RADIUS } from "../layout/window_layout.ts";
import { htmlDocument, type Composition } from "./composition.ts";
import type { EditorialPalette } from "./editorial_palette.ts";

export const DESKTOP_PLATE_FILE = "plate.png";

export type DesktopScreenshotRequest = {
  readonly id: string;
  readonly slot: Slot;
  readonly palette: EditorialPalette;
  readonly window: PixelRect;
  readonly bars: readonly CodeBar[];
  readonly critical: { readonly name: string; readonly rect: PixelRect };
};

const ROLE_OPACITY: Readonly<Record<CodeBarRole, number>> = { keyword: 1.6, number: 1.3, text: 1.1, symbol: 0.8, name: 1 };

export function buildDesktopScreenshot(request: DesktopScreenshotRequest): Composition {
  const { slot, id, palette, window } = request;
  const canvas = { width: slot.width, height: slot.height };
  const style = `#stage { background: ${palette.field}; }
#plate { position: absolute; left: ${window.x}px; top: ${window.y}px; width: ${window.width}px; height: ${window.height}px; border-radius: ${WINDOW_RADIUS}px;
box-shadow: 0 60px 140px rgba(7,45,47,.30), 0 0 0 2px rgba(7,45,47,.10); }`;
  const body = `${barsMarkup(request.bars, palette, canvas)}<img id="plate" src="${DESKTOP_PLATE_FILE}" alt="">`;
  const html = htmlDocument({ id, canvas, durationSeconds: 1, style, body, timeline: "" });
  const elements = [
    { name: "backdrop", rect: { x: 0, y: 0, ...canvas }, essential: false, content: "artwork" as const },
    { name: "window", rect: window, essential: false, content: "app-interface" as const },
    { name: request.critical.name, rect: request.critical.rect, essential: true, content: "app-interface" as const },
  ];
  return { id, canvas, durationSeconds: 1, html, layout: [{ timeSeconds: 0, elements }], texts: [] };
}

function barsMarkup(bars: readonly CodeBar[], palette: EditorialPalette, canvas: { width: number; height: number }): string {
  const rects = bars.map((bar) => `<rect x="${bar.x.toFixed(1)}" y="${bar.y.toFixed(1)}" width="${bar.width.toFixed(1)}" height="${bar.height}" rx="${bar.height / 2}" fill="${palette.texture}" opacity="${(palette.textureOpacity * ROLE_OPACITY[bar.role]).toFixed(3)}"/>`);
  return `<svg style="position:absolute;left:0;top:0" width="${canvas.width}" height="${canvas.height}">${rects.join("")}</svg>`;
}
