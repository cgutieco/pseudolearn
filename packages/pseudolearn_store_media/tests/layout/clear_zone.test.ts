import { describe, expect, it } from "vitest";
import { clearZone, intersection } from "../../src/layout/clear_zone.ts";
import { isClearIn } from "../../src/layout/crop_projection.ts";
import { toPixels } from "../../src/layout/pixel_rect.ts";
import { slot } from "../support/catalog.ts";

const header = slot("apple.header.video");

describe("clearZone", () => {
  it("lowers the top of the header zone below the iPad landscape tab bar", () => {
    const zone = clearZone(header);
    const official = toPixels(header.safeArea, { width: 3840, height: 1646 });
    expect(zone.y).toBeCloseTo(551.48, 1);
    expect(zone.x).toBeCloseTo(official.x, 6);
    expect(zone.y + zone.height).toBeCloseTo(official.y + official.height, 6);
  });

  it("leaves a zone that every header profile shows uncovered", () => {
    const zone = clearZone(header);
    for (const profile of header.viewportProfiles) {
      expect(isClearIn(profile, { width: 3840, height: 1646 }, { x: zone.x + 1, y: zone.y + 1, width: zone.width - 2, height: zone.height - 2 }), profile.name).toBe(true);
    }
  });

  it("keeps the official zone of a slot without profiles", () => {
    const search = slot("apple.search.video");
    expect(clearZone(search)).toEqual(toPixels(search.safeArea, { width: 3840, height: 2560 }));
  });

  it("collapses to nothing when an obstacle covers the whole zone", () => {
    const covered = { ...header, viewportProfiles: [{ name: "wall", viewport: { width: 3840, height: 1646 }, occlusions: [{ x: 0, y: 0, width: 3840, height: 1646 }] }] };
    const zone = clearZone(covered);
    expect(zone.width * zone.height).toBe(0);
  });

  it("trims the side that keeps the most room", () => {
    const pillar = { ...header, viewportProfiles: [{ name: "pillar", viewport: { width: 3840, height: 1646 }, occlusions: [{ x: 1000, y: 0, width: 300, height: 1646 }] }] };
    expect(clearZone(pillar).x).toBe(1300);
  });
});

describe("intersection", () => {
  it("returns an empty rectangle for disjoint rectangles", () => {
    expect(intersection({ x: 0, y: 0, width: 10, height: 10 }, { x: 20, y: 20, width: 5, height: 5 })).toEqual({ x: 20, y: 20, width: 0, height: 0 });
  });
});
