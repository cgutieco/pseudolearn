import { describe, expect, it } from "vitest";
import { auditImage } from "../../src/audit/image_audit.ts";
import { slot } from "../support/catalog.ts";
import { pngBytes } from "../support/png.ts";

const mac = slot("apple.mac.screenshot");

function rules(bytes: Uint8Array, target = mac): readonly string[] {
  return auditImage({ slot: target, target: "shot.png", bytes }).map((entry) => entry.rule);
}

describe("auditImage", () => {
  it("accepts an opaque 8-bit PNG of the slot size", () => {
    expect(rules(pngBytes({ width: 2880, height: 1800, colorType: 2 }))).toEqual([]);
  });

  it("rejects the wrong size", () => {
    expect(rules(pngBytes({ width: 2560, height: 1600, colorType: 2 }))).toEqual(["MEDIA-DIMENSIONS"]);
  });

  it("rejects an alpha channel and a transparency chunk", () => {
    expect(rules(pngBytes({ width: 2880, height: 1800, colorType: 6 }))).toEqual(["MEDIA-ALPHA"]);
    expect(rules(pngBytes({ width: 2880, height: 1800, colorType: 2, transparency: true }))).toEqual(["MEDIA-ALPHA"]);
  });

  it("rejects 16-bit depth", () => {
    expect(rules(pngBytes({ width: 2880, height: 1800, colorType: 2, bitDepth: 16 }))).toEqual(["MEDIA-FORMAT"]);
  });

  it("rejects a file over the slot limit", () => {
    const tile = slot("microsoft.tile-icon");
    const oversized = new Uint8Array(tile.maxBytes + 1);
    oversized.set(pngBytes({ width: 300, height: 300, colorType: 2 }));
    expect(rules(oversized, tile)).toEqual(["MEDIA-SIZE"]);
  });

  it("rejects bytes that are not a PNG, including an empty file", () => {
    expect(rules(new Uint8Array([0xff, 0xd8, 0xff]))).toEqual(["MEDIA-FORMAT"]);
    expect(rules(new Uint8Array(0))).toEqual(["MEDIA-FORMAT"]);
  });
});
