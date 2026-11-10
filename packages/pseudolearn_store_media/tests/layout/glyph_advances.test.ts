import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { describe, expect, it } from "vitest";
import { readGlyphAdvances, textWidth } from "../../src/layout/glyph_advances.ts";

const FONT = fileURLToPath(new URL("../../../pseudolearn_brand/assets/fonts/IBMPlexSans-Bold.ttf", import.meta.url));

function plexBold() {
  const reading = readGlyphAdvances(new Uint8Array(readFileSync(FONT)));
  if (!reading.ok) {
    throw new Error(reading.reason);
  }
  return reading.advances;
}

describe("readGlyphAdvances", () => {
  it("reads the brand headline face", () => {
    const advances = plexBold();
    expect(advances.unitsPerEm).toBe(1000);
    expect(advances.advanceOf("M".codePointAt(0) ?? 0)).toBeGreaterThan(advances.advanceOf("i".codePointAt(0) ?? 0) ?? 0);
    expect(advances.advanceOf("ñ".codePointAt(0) ?? 0)).not.toBeNull();
  });

  it("measures wider text as wider and scales with the font size", () => {
    const advances = plexBold();
    expect(textWidth(advances, "WWW", 100)).toBeGreaterThan(textWidth(advances, "iii", 100));
    expect(textWidth(advances, "Nodo", 200)).toBeCloseTo(2 * textWidth(advances, "Nodo", 100), 6);
    expect(textWidth(advances, "", 100)).toBe(0);
  });

  it("falls back to the space advance for a character the face lacks", () => {
    const advances = plexBold();
    expect(advances.advanceOf(0x1f600)).toBeNull();
    expect(textWidth(advances, "\u{1F600}", 100)).toBe(textWidth(advances, " ", 100));
  });
});

describe("readGlyphAdvances rejections", () => {
  it("rejects a truncated file", () => {
    expect(readGlyphAdvances(new Uint8Array(4))).toEqual({ ok: false, reason: "the font file is truncated" });
  });

  it("rejects a file without the metric tables", () => {
    const empty = new Uint8Array(12);
    expect(readGlyphAdvances(empty)).toEqual({ ok: false, reason: "the font lacks head, hhea, hmtx or cmap" });
  });
});
