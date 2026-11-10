import type { BrandCardPlacement } from "../layout/brand_card_layout.ts";
import { BRAND_GROUND_BOTTOM, BRAND_GROUND_TOP, BRAND_LOCKUP_HORIZONTAL_INVERSE_SVG } from "./brand.generated.ts";
import { viewBoxSize } from "./composition.ts";
import { escapeHtml, rectStyle } from "./html_text.ts";
import { time } from "./preview_markup.ts";

export const CARD_INK = "#E6ECED";
export const CARD_GROUND = BRAND_GROUND_BOTTOM;
export const CARD_FADE_SECONDS = 0.4;

export function lockupAspect(): number {
  const size = viewBoxSize(BRAND_LOCKUP_HORIZONTAL_INVERSE_SVG);
  return size.width / size.height;
}

export function brandCardMarkup(id: string, placed: BrandCardPlacement, lines: readonly string[]): string {
  const { card } = placed;
  const lockup = BRAND_LOCKUP_HORIZONTAL_INVERSE_SVG.replace("<svg", '<svg style="width:100%;height:100%;display:block"');
  const text = placed.text && placed.fit
    ? `<div class="sans" style="position:absolute;left:0;top:${placed.text.y - card.y}px;width:${card.width}px;text-align:center;
font-size:${placed.fit.fontSize}px;line-height:1.2;color:${CARD_INK}">${lines.map(escapeHtml).join("<br>")}</div>`
    : "";
  return `<div id="${id}" class="overlay" style="${rectStyle(card)}border-radius:${Math.min(card.width, card.height) * 0.16}px;
background:linear-gradient(180deg, ${BRAND_GROUND_TOP}, ${CARD_GROUND});box-shadow:0 30px 80px rgba(0,0,0,.35);z-index:80">
<div style="position:absolute;left:${placed.lockup.x - card.x}px;top:${placed.lockup.y - card.y}px;width:${placed.lockup.width}px;height:${placed.lockup.height}px">${lockup}</div>
${text}</div>`;
}

export function brandCardLines(id: string, window: { start: number; end: number; opening: boolean }): readonly string[] {
  const fadeOut = `timeline.to("#${id}", { opacity: 0, duration: ${CARD_FADE_SECONDS}, ease: "sine.in" }, ${time(window.end - CARD_FADE_SECONDS)});`;
  return window.opening
    ? [`timeline.set("#${id}", { opacity: 1 }, 0);`, fadeOut]
    : [`timeline.to("#${id}", { opacity: 1, duration: ${CARD_FADE_SECONDS}, ease: "sine.out" }, ${time(window.start)});`];
}
