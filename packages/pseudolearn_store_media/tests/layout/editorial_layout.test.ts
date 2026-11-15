import { describe, expect, it } from "vitest";
import { editorialLayout } from "../../src/layout/editorial_layout.ts";
import { contains, toPixels } from "../../src/layout/pixel_rect.ts";
import { realCatalog, slot } from "../support/catalog.ts";

function layoutOf(id: string, kind: "manifesto" | "device") {
  const target = slot(id);
  const canvas = { width: target.width, height: target.height };
  const safe = toPixels(target.safeArea, canvas);
  if (!target.device) {
    throw new Error(id);
  }
  return { canvas, safe, layout: editorialLayout({ canvas, safe, device: target.device, kind }) };
}

const screenshotSlots = realCatalog().slots.filter((entry) => entry.device).map((entry) => entry.id);

describe("editorialLayout", () => {
  it("keeps every text box inside the margin on every slot and kind", () => {
    for (const id of screenshotSlots) {
      for (const kind of ["manifesto", "device"] as const) {
        const { safe, layout } = layoutOf(id, kind);
        for (const box of [layout.headline, layout.subline, layout.code].filter((entry) => entry !== null)) {
          expect(contains(safe, box), `${id} ${kind}`).toBe(true);
        }
      }
    }
  });

  it("bleeds the device off the bottom in portrait and off the right in landscape", () => {
    const portrait = layoutOf("apple.iphone.screenshot", "device");
    const landscape = layoutOf("apple.mac.screenshot", "device");
    const tall = portrait.layout.device?.outer;
    const wide = landscape.layout.device?.outer;
    expect((tall?.y ?? 0) + (tall?.height ?? 0)).toBeGreaterThan(portrait.canvas.height);
    expect((wide?.x ?? 0) + (wide?.width ?? 0)).toBeGreaterThan(landscape.canvas.width);
    expect(wide?.y).toBeGreaterThanOrEqual(landscape.safe.y);
  });

  it("places the device below the headline in portrait and beside it in landscape", () => {
    const portrait = layoutOf("apple.iphone-duo-outer.screenshot.portrait", "device").layout;
    const landscape = layoutOf("apple.iphone-duo-inner.screenshot.landscape", "device").layout;
    expect(portrait.device?.outer.y).toBeGreaterThan(portrait.headline.y + portrait.headline.height);
    expect(landscape.device?.outer.x).toBeGreaterThan(landscape.headline.x + landscape.headline.width);
  });

});

describe("editorialLayout by chapter kind", () => {
  it("tilts the device of a portrait manifesto and drops it in a landscape one", () => {
    expect(layoutOf("apple.ipad.screenshot", "manifesto").layout.device?.rotation).toBe(-4);
    const landscape = layoutOf("apple.mac.screenshot", "manifesto").layout;
    expect(landscape.device).toBeNull();
    expect(landscape.code).not.toBeNull();
  });

  it("gives a device chapter neither subline nor code card", () => {
    const { layout } = layoutOf("apple.iphone.screenshot", "device");
    expect(layout.subline).toBeNull();
    expect(layout.code).toBeNull();
  });
});
