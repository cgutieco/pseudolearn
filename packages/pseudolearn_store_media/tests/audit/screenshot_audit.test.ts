import { describe, expect, it } from "vitest";
import { auditFocus, auditHeadlineFit, auditPlate } from "../../src/audit/screenshot_audit.ts";
import { slot } from "../support/catalog.ts";
import { pngBytes } from "../support/png.ts";

const mac = slot("apple.mac.screenshot").device;

describe("auditPlate", () => {
  it("accepts a plate at the device's logical size times its scale", () => {
    expect(mac && auditPlate("p", mac, pngBytes({ width: 2880, height: 1800, colorType: 2 }))).toEqual([]);
  });

  it("rejects a missing plate, a non-PNG and a plate of another size", () => {
    if (!mac) {
      throw new Error("fixture");
    }
    expect(auditPlate("p", mac, null)[0]?.rule).toBe("MEDIA-PLATE");
    expect(auditPlate("p", mac, new Uint8Array([1, 2, 3]))[0]?.message).toBe("not a PNG file");
    expect(auditPlate("p", mac, pngBytes({ width: 1440, height: 900, colorType: 2 }))[0]?.message).toBe("1440×900 instead of 2880×1800 for mac");
  });
});

describe("auditHeadlineFit", () => {
  it("accepts a fitting headline", () => {
    expect(auditHeadlineFit("h", { fits: true, fontSize: 90, width: 10, height: 10 })).toEqual([]);
  });

  it("names the overflowing lines", () => {
    const [entry] = auditHeadlineFit("h", { fits: false, fontSize: 40, overflowingLines: ["too wide"] });
    expect(entry).toEqual({ rule: "TEXT-FIT", target: "h", message: '"too wide" does not fit at the minimum size of 40px' });
  });
});

describe("auditFocus", () => {
  it("accepts a recorded focus and a chapter that needs none", () => {
    expect(auditFocus("p", "trace", ["trace", "output"])).toEqual([]);
    expect(auditFocus("p", null, null)).toEqual([]);
  });

  it("rejects a missing timeline and a focus the plate never recorded", () => {
    expect(auditFocus("p", "trace", null)[0]?.message).toBe("the plate has no readable timeline.json with focus rectangles");
    expect(auditFocus("p", "trace", [])[0]?.message).toBe("the plate did not record the focus trace; it has none");
  });
});
