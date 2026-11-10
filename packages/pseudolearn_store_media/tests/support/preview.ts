import type { PlateTimeline } from "../../src/story/plate_timeline.ts";
import { parsePreviewStory, type PreviewStory } from "../../src/story/preview_story.ts";

const RUN_CAPTION = { role: "headline", text: { es: "Tu programa\n*cobra vida.*", en: "Your program\n*comes alive.*" }, from: 0.5, to: 5 };
const NODO_PIN = { focus: "verified-code", pin: { x: 0.1, y: 0 }, note: { es: "Verificado", en: "Checked" }, from: 1, to: 6 };

export function previewDocument(): Record<string, unknown> {
  return {
    id: "test-previews",
    brand: { opening: 2, closing: 3 },
    disclosure: { plates: ["preview-nodo"], text: { es: "Nodo requiere sesión y suscripción.", en: "Nodo needs sign-in and a subscription." } },
    previews: [{
      id: "overview",
      posterSeconds: 5,
      scenes: [
        { plate: "preview-run", appTheme: "light", palette: "mint", from: 0, to: 9, touches: true, captions: [RUN_CAPTION] },
        { plate: "preview-nodo", appTheme: "dark", palette: "deep", from: 1, to: 9, transition: { kind: "dissolve", seconds: 0.6 },
          pins: [NODO_PIN], captions: [{ role: "disclosure", text: { es: "Nodo requiere suscripción.", en: "Nodo requires a subscription." }, from: 5, to: 8 }] },
      ],
    }],
  };
}

export function previewStory(): PreviewStory {
  const parsed = parsePreviewStory(previewDocument());
  if (!parsed.ok) {
    throw new Error(parsed.errors.map((error) => `${error.path}: ${error.message}`).join("\n"));
  }
  return parsed.value;
}

export function plateTimeline(scene: string, seconds: number, events: PlateTimeline["events"] = []): PlateTimeline {
  const frames = Array.from({ length: Math.round(seconds * 30) }, (_, index) => ({
    index, file: `frame_${String(index + 1).padStart(6, "0")}.png`, focus: [{ key: "verified-code", x: 100, y: 900, width: 600, height: 400 }],
  }));
  return { scene, language: "es", fps: 30, pixelWidth: 886, pixelHeight: 1920, frames, events };
}
