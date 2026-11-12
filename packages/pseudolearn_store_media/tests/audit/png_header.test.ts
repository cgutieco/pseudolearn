import { describe, expect, it } from "vitest";
import { hasAlphaChannel, hasTransparencyChunk, readPngHeader } from "../../src/audit/png_header.ts";
import { pngBytes } from "../support/png.ts";

describe("readPngHeader", () => {
  it("reads size, depth and colour type", () => {
    const reading = readPngHeader(pngBytes({ width: 1, height: 65535, colorType: 2 }));
    expect(reading).toEqual({ ok: true, header: { width: 1, height: 65535, bitDepth: 8, colorType: 2 } });
  });

  it("rejects a truncated file", () => {
    expect(readPngHeader(pngBytes({ width: 1, height: 1, colorType: 2 }).subarray(0, 20)).ok).toBe(false);
  });

  it("rejects a file whose first chunk is not IHDR", () => {
    const bytes = pngBytes({ width: 1, height: 1, colorType: 2 });
    bytes.set([0x49, 0x44, 0x41, 0x54], 12);
    expect(readPngHeader(bytes)).toEqual({ ok: false, reason: "the first chunk is not IHDR" });
  });
});

describe("transparency", () => {
  it("knows which colour types carry alpha", () => {
    expect(hasAlphaChannel({ width: 1, height: 1, bitDepth: 8, colorType: 6 })).toBe(true);
    expect(hasAlphaChannel({ width: 1, height: 1, bitDepth: 8, colorType: 4 })).toBe(true);
    expect(hasAlphaChannel({ width: 1, height: 1, bitDepth: 8, colorType: 2 })).toBe(false);
  });

  it("finds a tRNS chunk before the image data and ignores one after it", () => {
    expect(hasTransparencyChunk(pngBytes({ width: 1, height: 1, colorType: 2, transparency: true }))).toBe(true);
    expect(hasTransparencyChunk(pngBytes({ width: 1, height: 1, colorType: 2 }))).toBe(false);
  });
});
