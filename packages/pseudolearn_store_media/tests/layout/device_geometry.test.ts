import { describe, expect, it } from "vitest";
import { deviceAspect, fitDevice, placeDevice } from "../../src/layout/device_geometry.ts";
import { contains } from "../../src/layout/pixel_rect.ts";
import { realCatalog } from "../support/catalog.ts";

const devices = new Map(realCatalog().devices.map((device) => [device.id, device]));

function device(id: string) {
  const found = devices.get(id);
  if (!found) {
    throw new Error(id);
  }
  return found;
}

describe("placeDevice", () => {
  it("keeps the screen at the aspect of the logical size inside the frame", () => {
    for (const entry of devices.values()) {
      const placement = placeDevice(entry, { x: 10, y: 20, width: 1000, rotation: 0 });
      expect(placement.screen.width / placement.screen.height, entry.id).toBeCloseTo(entry.logicalWidth / entry.logicalHeight, 6);
      expect(contains(placement.outer, placement.screen), entry.id).toBe(true);
    }
  });

  it("gives the laptop a base wider than its lid", () => {
    const placement = placeDevice(device("mac"), { x: 0, y: 0, width: 1000, rotation: 0 });
    expect(placement.screen.x).toBeGreaterThan(0.06 * placement.screen.width);
    expect(placement.outer.height - (placement.screen.y + placement.screen.height)).toBeGreaterThan(placement.screen.y);
  });

  it("scales the corner radius with the screen", () => {
    const phone = device("iphone-large");
    const small = placeDevice(phone, { x: 0, y: 0, width: 500, rotation: 0 });
    const large = placeDevice(phone, { x: 0, y: 0, width: 1000, rotation: 0 });
    expect(large.screenRadius).toBeCloseTo(2 * small.screenRadius, 6);
  });
});

describe("fitDevice", () => {
  it("fits by width in a tall region and by height in a wide one", () => {
    const phone = device("iphone-large");
    expect(fitDevice(phone, { x: 0, y: 0, width: 100, height: 10_000 }).outer.width).toBeCloseTo(100, 6);
    expect(fitDevice(phone, { x: 0, y: 0, width: 10_000, height: 100 }).outer.height).toBeCloseTo(100, 6);
    expect(deviceAspect(phone)).toBeLessThan(1);
  });

  it("handles a zero-sized region without leaving it", () => {
    const placement = fitDevice(device("mac"), { x: 5, y: 5, width: 0, height: 0 });
    expect(placement.outer.width).toBe(0);
  });
});
