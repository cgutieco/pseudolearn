import type { PixelRect, Size } from "../layout/pixel_rect.ts";
import type { RunLines } from "../story/headline_runs.ts";
import { CODE_CARD, type EditorialPalette } from "./editorial_palette.ts";
import { escapeHtml, rectStyle } from "./html_text.ts";

export const SANS_FONT_FILE = "headline.ttf";
export const MONO_FONT_FILE = "mono.ttf";
export const HEADLINE_LINE_HEIGHT = 1.02;
export const MONO_LINE_HEIGHT = 1.45;

export type PlacedText = { readonly rect: PixelRect; readonly size: number };

export function editorialStyle(canvas: Size, palette: EditorialPalette): string {
  return `@font-face { font-family: "Sans"; src: url("${SANS_FONT_FILE}"); font-weight: 700; }
@font-face { font-family: "Mono"; src: url("${MONO_FONT_FILE}"); font-weight: 500; }
#stage { background: ${palette.field}; overflow: hidden; width: ${canvas.width}px; height: ${canvas.height}px; }
.sans { font-family: "Sans"; font-weight: 700; white-space: pre; }
.mono { font-family: "Mono"; font-weight: 500; white-space: pre; }
.hl { background: linear-gradient(transparent 58%, ${palette.marker} 58%); padding: 0 0.05em; }
.kw { color: ${CODE_CARD.keyword}; } .lit { color: ${CODE_CARD.literal}; }`;
}

export function textureMarkup(lines: readonly string[], canvas: Size, palette: EditorialPalette): string {
  const unit = Math.min(canvas.width, canvas.height);
  const rows = lines.map((line, index) => `<div style="margin-left:${(index % 3) * unit * 0.1}px">${escapeHtml(line)}</div>`).join("");
  return `<div class="mono" style="position:absolute;left:${-0.17 * canvas.width}px;top:${0.22 * canvas.height}px;width:${1.7 * canvas.width}px;
transform:rotate(-8deg);font-size:${0.085 * unit}px;line-height:1.35;color:${palette.texture};opacity:${palette.textureOpacity}">${rows}</div>`;
}

export function labelMarkup(text: string, placed: PlacedText, palette: EditorialPalette): string {
  return `<div class="sans" style="position:absolute;left:${placed.rect.x}px;top:${placed.rect.y}px;font-size:${placed.size}px;letter-spacing:.2em;color:${palette.label}">${escapeHtml(text)}</div>`;
}

export function headlineMarkup(runs: RunLines, placed: PlacedText, palette: EditorialPalette): string {
  const lines = runs.map((line) => line.map((run) => (run.marked ? `<span class="hl">${escapeHtml(run.text)}</span>` : escapeHtml(run.text))).join(""));
  return `<div class="sans" style="position:absolute;left:${placed.rect.x}px;top:${placed.rect.y}px;font-size:${placed.size}px;line-height:${HEADLINE_LINE_HEIGHT};
letter-spacing:-0.03em;color:${palette.ink}">${lines.join("<br>")}</div>`;
}

export function sublineMarkup(lines: readonly string[], placed: PlacedText, palette: EditorialPalette): string {
  return `<div class="mono" style="position:absolute;left:${placed.rect.x}px;top:${placed.rect.y}px;font-size:${placed.size}px;line-height:${MONO_LINE_HEIGHT};color:${palette.ink};opacity:.82">${lines.map(escapeHtml).join("<br>")}</div>`;
}

export function codeCardMarkup(lines: readonly string[], card: PixelRect, placed: PlacedText): string {
  const rows = lines.map((line) => escapeHtml(line)
    .replace(/^(\s*)(\S+)/u, "$1<span class=\"kw\">$2</span>")
    .replace(/(&quot;.*?&quot;)/gu, "<span class=\"lit\">$1</span>"));
  return `<div style="${rectStyle(card)}border-radius:${card.height * 0.12}px;background:${CODE_CARD.background};box-shadow:0 50px 120px rgba(7,45,47,.35)"></div>
<div class="mono" style="position:absolute;left:${placed.rect.x}px;top:${placed.rect.y}px;font-size:${placed.size}px;line-height:${MONO_LINE_HEIGHT};color:${CODE_CARD.ink}">${rows.join("<br>")}</div>`;
}

export function highlightMarkup(rect: PixelRect, palette: EditorialPalette, weight: number): string {
  const pad = weight * 1.6;
  return `<div style="position:absolute;left:${rect.x - pad}px;top:${rect.y - pad}px;width:${rect.width + 2 * pad}px;height:${rect.height + 2 * pad}px;
border-radius:${weight * 5}px;border:${weight}px solid ${palette.frame};box-shadow:0 0 0 9999px ${palette.veil}"></div>`;
}

export function pinMarkup(point: { x: number; y: number }, pill: PlacedText & { readonly text: string }, palette: EditorialPalette): string {
  const dot = pill.size * 0.8;
  return `<div style="position:absolute;left:${point.x - dot / 2}px;top:${point.y - dot / 2}px;width:${dot}px;height:${dot}px;border-radius:50%;background:${palette.pill};box-shadow:0 0 0 ${dot * 0.38}px ${palette.veil}"></div>
<div class="sans" style="${rectStyle(pill.rect)}border-radius:999px;background:${palette.pill};color:${palette.pillInk};font-size:${pill.size}px;line-height:${pill.rect.height}px;text-align:center;box-shadow:0 24px 60px rgba(0,0,0,.25)">${escapeHtml(pill.text)}</div>`;
}

export function grainMarkup(): string {
  return `<svg style="position:absolute;inset:0;width:100%;height:100%;opacity:.05;mix-blend-mode:overlay" xmlns="http://www.w3.org/2000/svg">
<filter id="grain"><feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="2" seed="7" stitchTiles="stitch"/><feColorMatrix type="saturate" values="0"/></filter>
<rect width="100%" height="100%" filter="url(#grain)"/></svg>`;
}
