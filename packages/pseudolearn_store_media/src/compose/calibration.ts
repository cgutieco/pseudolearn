import type { Slot } from "../catalog/catalog_types.ts";
import { centeredIn, toPixels, type PixelRect } from "../layout/pixel_rect.ts";
import type { Beat } from "../story/storyboard.ts";
import {
  BRAND_GROUND_BOTTOM,
  BRAND_GROUND_TOP,
  BRAND_INK,
  BRAND_LOCKUP_HORIZONTAL_INVERSE_SVG,
  BRAND_SYMBOL_CENTERLINE,
  BRAND_SYMBOL_STROKE,
  BRAND_SYMBOL_VIEW_BOX,
} from "./brand.generated.ts";
import { htmlDocument, viewBoxSize, type Composition } from "./composition.ts";

export type CalibrationRequest = {
  readonly slot: Slot;
  readonly durationSeconds: number;
  readonly beats: readonly Beat[];
  readonly guides: boolean;
};

const LOCKUP_SHARE_OF_SAFE_AREA = 0.8;
const PULSE_SECONDS = 0.4;
const PULSE_GAIN = 0.03;
const MAXIMUM_PULSE = 1 + PULSE_GAIN;

export function buildCalibration(request: CalibrationRequest): Composition {
  const { slot, durationSeconds } = request;
  const canvas = { width: slot.width, height: slot.height };
  const safe = toPixels(slot.safeArea, canvas);
  const lockup = lockupRect(safe);
  const id = `calibration-${slot.id.replaceAll(".", "-")}`;
  const html = htmlDocument({
    id,
    canvas,
    durationSeconds,
    style: style(canvas, lockup),
    body: body({ safe, guides: request.guides }),
    timeline: timeline(request),
  });
  return {
    id,
    canvas,
    durationSeconds,
    html,
    layout: [{ timeSeconds: 0, elements: [{ name: "lockup", rect: scaledAbout(lockup, MAXIMUM_PULSE), essential: true }] }],
    texts: [],
  };
}

function lockupRect(safe: PixelRect): PixelRect {
  const ratio = viewBoxSize(BRAND_LOCKUP_HORIZONTAL_INVERSE_SVG);
  const width = Math.min(safe.width * LOCKUP_SHARE_OF_SAFE_AREA,
    (safe.height * LOCKUP_SHARE_OF_SAFE_AREA * ratio.width) / ratio.height);
  return centeredIn(safe, { width, height: (width * ratio.height) / ratio.width });
}

function scaledAbout(rect: PixelRect, factor: number): PixelRect {
  const width = rect.width * factor;
  const height = rect.height * factor;
  return { x: rect.x - (width - rect.width) / 2, y: rect.y - (height - rect.height) / 2, width, height };
}

function style(canvas: { width: number; height: number }, lockup: PixelRect): string {
  const watermark = Math.min(canvas.width, canvas.height) * 1.1;
  return `#stage { background: linear-gradient(180deg, ${BRAND_GROUND_TOP}, ${BRAND_GROUND_BOTTOM}); }
#route { position: absolute; width: ${watermark}px; height: ${watermark}px;
  left: ${(canvas.width - watermark) / 2}px; top: ${(canvas.height - watermark) / 2}px; opacity: 0.16; }
#lockup { position: absolute; left: ${lockup.x}px; top: ${lockup.y}px; width: ${lockup.width}px; height: ${lockup.height}px; }
#lockup svg { width: 100%; height: 100%; display: block; }
#guide { position: absolute; border: 2px dashed ${BRAND_INK}; opacity: 0.7; }`;
}

function body(context: { safe: PixelRect; guides: boolean }): string {
  const { safe, guides } = context;
  const guide = guides
    ? `<div id="guide" style="left:${safe.x}px;top:${safe.y}px;width:${safe.width}px;height:${safe.height}px"></div>`
    : "";
  return `<svg id="route" viewBox="${BRAND_SYMBOL_VIEW_BOX}"><path id="route-line" d="${BRAND_SYMBOL_CENTERLINE}"
 pathLength="1" fill="none" stroke="${BRAND_INK}" stroke-width="${BRAND_SYMBOL_STROKE}" stroke-linecap="round"
 stroke-linejoin="round" stroke-dasharray="1" stroke-dashoffset="1"/></svg>
<div id="lockup">${BRAND_LOCKUP_HORIZONTAL_INVERSE_SVG}</div>
${guide}`;
}

function timeline(request: CalibrationRequest): string {
  const half = request.durationSeconds / 2;
  const lines = [
    `timeline.fromTo("#route-line", { strokeDashoffset: 1 }, { strokeDashoffset: 0, duration: ${half}, ease: "sine.inOut" }, 0);`,
    `timeline.to("#route-line", { strokeDashoffset: -1, duration: ${half}, ease: "sine.inOut" }, ${half});`,
    `timeline.set("#route-line", { strokeDashoffset: 1 }, ${request.durationSeconds});`,
  ];
  for (const beat of request.beats) {
    if (beat.atSeconds + PULSE_SECONDS < request.durationSeconds) {
      const peak = 1 + PULSE_GAIN * beat.weight;
      lines.push(`timeline.to("#lockup", { scale: ${peak}, duration: ${PULSE_SECONDS / 2}, yoyo: true, repeat: 1, ease: "sine.out" }, ${beat.atSeconds});`);
    }
  }
  return lines.join("\n");
}
