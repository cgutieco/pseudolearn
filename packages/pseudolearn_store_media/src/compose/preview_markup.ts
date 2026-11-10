import type { CaptionPlacement } from "../layout/preview_layout.ts";
import { CAPTION_LINE_HEIGHT } from "../layout/preview_layout.ts";
import type { PixelRect } from "../layout/pixel_rect.ts";
import { headlineRuns } from "../story/headline_runs.ts";
import type { EditorialPalette } from "./editorial_palette.ts";
import { escapeHtml, rectStyle } from "./html_text.ts";

export const FADE_SECONDS = 0.3;

export function time(seconds: number): number {
  return Number(seconds.toFixed(6));
}

export function previewStyle(fontFile: string): string {
  return `@font-face { font-family: "Sans"; src: url("${fontFile}"); font-weight: 700; }
.plate { position: absolute; left: 0; top: 0; }
.overlay { position: absolute; opacity: 0; }
.sans { font-family: "Sans"; font-weight: 700; white-space: pre; }`;
}

export function plateMarkup(id: string, placement: { src: string; start: number; duration: number; mediaStart: number; size: { width: number; height: number } }): string {
  return `<video id="${id}" class="clip plate" src="${placement.src}" muted data-start="${time(placement.start)}" data-duration="${time(placement.duration)}"
 data-media-start="${time(placement.mediaStart)}" style="width:${placement.size.width}px;height:${placement.size.height}px"></video>`;
}

export function captionMarkup(id: string, text: string, placed: CaptionPlacement, palette: EditorialPalette): string {
  const runs = headlineRuns(text) ?? [];
  const lines = runs.map((line) => line.map((run) => (run.marked
    ? `<span style="background:linear-gradient(transparent 58%, ${palette.marker} 58%)">${escapeHtml(run.text)}</span>`
    : escapeHtml(run.text))).join(""));
  const radius = Math.min(placed.panel.height, placed.panel.width) * 0.18;
  return `<div id="${id}" class="overlay" style="${rectStyle(placed.panel)}border-radius:${radius}px;background:${palette.field};box-shadow:0 18px 48px rgba(0,0,0,.18)">
<div class="sans" style="position:absolute;left:${placed.text.x - placed.panel.x}px;top:${placed.text.y - placed.panel.y}px;font-size:${placed.fit.fontSize}px;
line-height:${CAPTION_LINE_HEIGHT};letter-spacing:-0.02em;color:${palette.ink}">${lines.join("<br>")}</div></div>`;
}

export type PinPlacement = { readonly point: { x: number; y: number }; readonly pill: PixelRect; readonly fontSize: number; readonly text: string };

export function pinOverlayMarkup(id: string, placed: PinPlacement, palette: EditorialPalette): string {
  const dot = placed.fontSize * 0.8;
  return `<div id="${id}" class="overlay" style="left:0;top:0">
<div style="position:absolute;left:${placed.point.x - dot / 2}px;top:${placed.point.y - dot / 2}px;width:${dot}px;height:${dot}px;border-radius:50%;background:${palette.pill};box-shadow:0 0 0 ${dot * 0.38}px ${palette.veil}"></div>
<div class="sans" style="${rectStyle(placed.pill)}border-radius:999px;background:${palette.pill};color:${palette.pillInk};font-size:${placed.fontSize}px;line-height:${placed.pill.height}px;text-align:center;box-shadow:0 16px 40px rgba(0,0,0,.25)">${escapeHtml(placed.text)}</div></div>`;
}

export function touchMarkup(id: string, point: { x: number; y: number }, diameter: number): string {
  return `<div id="${id}" class="overlay" style="left:${point.x - diameter / 2}px;top:${point.y - diameter / 2}px;width:${diameter}px;height:${diameter}px;
border-radius:50%;background:rgba(255,255,255,.38);border:${diameter * 0.06}px solid rgba(255,255,255,.9);box-shadow:0 0 0 ${diameter * 0.04}px rgba(0,0,0,.18)"></div>`;
}

export function fadeLines(id: string, window: { start: number; end: number }): readonly string[] {
  const fade = Math.min(FADE_SECONDS, (window.end - window.start) / 3);
  return [
    `timeline.to("#${id}", { opacity: 1, duration: ${time(fade)}, ease: "sine.out" }, ${time(window.start)});`,
    `timeline.to("#${id}", { opacity: 0, duration: ${time(fade)}, ease: "sine.in" }, ${time(window.end - fade)});`,
  ];
}

export function touchLines(id: string, window: { start: number; end: number }): readonly string[] {
  const half = (window.end - window.start) / 2;
  return [
    `timeline.fromTo("#${id}", { opacity: 0, scale: 0.6 }, { opacity: 1, scale: 1, duration: ${time(half)}, ease: "sine.out" }, ${time(window.start)});`,
    `timeline.to("#${id}", { opacity: 0, scale: 1.25, duration: ${time(half)}, ease: "sine.in" }, ${time(window.start + half)});`,
  ];
}

export function dissolveLine(id: string, window: { start: number; seconds: number }): string {
  return `timeline.fromTo("#${id}", { opacity: 0 }, { opacity: 1, duration: ${time(window.seconds)}, ease: "none" }, ${time(window.start)});`;
}
