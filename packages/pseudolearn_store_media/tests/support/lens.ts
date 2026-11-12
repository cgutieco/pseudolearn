import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import type { TextMeasure } from "../../src/layout/lens_layout.ts";
import { readGlyphAdvances, type GlyphAdvances } from "../../src/layout/glyph_advances.ts";
import { parseLensStory, type LensStory } from "../../src/story/lens_story.ts";
import type { LoadedFont } from "../../src/pipeline/produce_screenshot.ts";

const packageRoot = fileURLToPath(new URL("../../", import.meta.url));

export function lensDocument(): Record<string, unknown> {
  return JSON.parse(readFileSync(`${packageRoot}stories/app-store-creative.json`, "utf8")) as Record<string, unknown>;
}

export function shippedLensStory(): LensStory {
  const parsed = parseLensStory(lensDocument());
  if (!parsed.ok) {
    throw new Error(parsed.errors.map((error) => `${error.path}: ${error.message}`).join("\n"));
  }
  return parsed.value;
}

export const SIMPLE_MEASURE: TextMeasure = {
  mono: (text, size) => text.length * size * 0.6,
  sans: (text, size) => text.length * size * 0.5,
};

export function brandFont(file: string): LoadedFont {
  const bytes = new Uint8Array(readFileSync(`${packageRoot}../pseudolearn_brand/assets/fonts/${file}`));
  const reading = readGlyphAdvances(bytes);
  if (!reading.ok) {
    throw new Error(reading.reason);
  }
  return { bytes, advances: reading.advances };
}

export function uniformFont(emShare: number): LoadedFont {
  const advances: GlyphAdvances = { unitsPerEm: 1000, advanceOf: () => emShare * 1000 };
  return { bytes: new Uint8Array([1]), advances };
}
