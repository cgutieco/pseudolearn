import type { FrameLayout } from "../layout/safe_area_check.ts";
import type { Size } from "../layout/pixel_rect.ts";

export const TIMELINE_LIBRARY = "gsap.min.js";

export type Composition = {
  readonly id: string;
  readonly canvas: Size;
  readonly durationSeconds: number;
  readonly html: string;
  readonly layout: readonly FrameLayout[];
  readonly texts: readonly string[];
};

export type DocumentParts = {
  readonly id: string;
  readonly canvas: Size;
  readonly durationSeconds: number;
  readonly style: string;
  readonly body: string;
  readonly timeline: string;
};

export function htmlDocument(parts: DocumentParts): string {
  const { id, canvas, durationSeconds } = parts;
  return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=${canvas.width}, height=${canvas.height}">
<script src="${TIMELINE_LIBRARY}"></script>
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
html, body { width: ${canvas.width}px; height: ${canvas.height}px; overflow: hidden; }
.clip { position: absolute; inset: 0; visibility: hidden; }
${parts.style}
</style>
</head>
<body>
<div id="root" data-composition-id="${id}" data-start="0" data-width="${canvas.width}" data-height="${canvas.height}">
<div id="stage" class="clip" data-start="0" data-duration="${durationSeconds}" data-track-index="0">
${parts.body}
</div>
</div>
<script>
const timeline = gsap.timeline({ paused: true });
${parts.timeline}
timeline.set({}, {}, ${durationSeconds});
window.__timelines = window.__timelines || {};
window.__timelines["${id}"] = timeline;
</script>
</body>
</html>
`;
}

export function viewBoxSize(svg: string): Size {
  const match = /viewBox="\s*[-\d.]+[\s,]+[-\d.]+[\s,]+([\d.]+)[\s,]+([\d.]+)\s*"/u.exec(svg);
  return { width: Number(match?.[1] ?? 0), height: Number(match?.[2] ?? 0) };
}
