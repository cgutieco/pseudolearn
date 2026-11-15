import { describe, expect, it } from "vitest";
import { deviceMarkup } from "../../src/compose/device_markup.ts";
import { placeDevice } from "../../src/layout/device_geometry.ts";
import { realCatalog } from "../support/catalog.ts";

function markupFor(id: string, rotation = 0): string {
  const device = realCatalog().devices.find((entry) => entry.id === id);
  if (!device) {
    throw new Error(id);
  }
  return deviceMarkup({ device, placement: placeDevice(device, { x: 0, y: 0, width: 1000, rotation }), plateFile: "plate.png" });
}

describe("deviceMarkup", () => {
  it("draws one screen for a phone and a tablet", () => {
    expect(markupFor("iphone-large").match(/plate\.png/gu)).toHaveLength(1);
    expect(markupFor("ipad-13").match(/plate\.png/gu)).toHaveLength(1);
  });

  it("draws two hinged halves for a foldable and a base for the laptop", () => {
    expect(markupFor("iphone-duo-inner-landscape").match(/plate\.png/gu)).toHaveLength(2);
    expect(markupFor("mac")).toContain("#d4d9db");
  });

  it("applies the rotation of the placement", () => {
    expect(markupFor("iphone-large", -4)).toContain("rotate(-4deg)");
    expect(markupFor("iphone-large")).toContain("rotate(0deg)");
  });
});
