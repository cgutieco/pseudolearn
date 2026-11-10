import { describe, expect, it } from "vitest";
import { parseCatalog } from "../../src/catalog/parse_catalog.ts";
import { lexiconDocument, realCatalog, slotsDocument } from "../support/catalog.ts";

type Mutable = Record<string, unknown>;

function errorsAfter(change: (document: Mutable) => void): readonly string[] {
  const document = slotsDocument();
  change(document);
  const parsed = parseCatalog(document, lexiconDocument());
  return parsed.ok ? [] : parsed.errors.map((error) => `${error.path}: ${error.message}`);
}

function devices(document: Mutable): Mutable[] {
  return document["devices"] as Mutable[];
}

function slotNamed(document: Mutable, id: string): Mutable {
  return (document["slots"] as Mutable[]).find((entry) => entry["id"] === id) as Mutable;
}

describe("device catalog", () => {
  it("frames every Apple screenshot slot in a device whose plate fills the slot exactly", () => {
    const screenshots = realCatalog().slots.filter((slot) => slot.store === "app-store" && slot.kind === "screenshot");
    expect(screenshots).toHaveLength(7);
    for (const slot of screenshots) {
      const device = slot.device;
      expect(device, slot.id).not.toBeNull();
      expect((device?.logicalWidth ?? 0) * (device?.plateScale ?? 0) / slot.width).toBeCloseTo(
        (device?.logicalHeight ?? 0) * (device?.plateScale ?? 0) / slot.height, 1);
    }
  });

  it("keeps the measured iPhone Duo poses and their fold axes", () => {
    const byId = new Map(realCatalog().devices.map((device) => [device.id, device]));
    expect(byId.get("iphone-duo-inner-landscape")).toMatchObject({ logicalWidth: 951, logicalHeight: 669, fold: "vertical" });
    expect(byId.get("iphone-duo-inner-portrait")).toMatchObject({ logicalWidth: 669, logicalHeight: 951, fold: "horizontal" });
    expect(byId.get("iphone-duo-outer-portrait")).toMatchObject({ logicalWidth: 466, logicalHeight: 678, fold: "none" });
  });

  it("accepts the smallest valid device", () => {
    const errors = errorsAfter((document) => {
      devices(document).push({ id: "x", logicalWidth: 100, logicalHeight: 100, plateScale: 1, cornerRadius: 0, frame: "phone", fold: "none" });
    });
    expect(errors).toEqual([]);
  });
});

describe("device catalog rejections", () => {
  it("rejects a duplicate device and a fold on a frame that cannot fold", () => {
    const errors = errorsAfter((document) => {
      const first = devices(document)[0] as Mutable;
      devices(document).push({ ...first });
      first["fold"] = "vertical";
    });
    expect(errors).toContain("devices: duplicate device id iphone-large");
    expect(errors).toContain("devices[0].fold: only a foldable frame has a fold axis, and it always has one");
  });

  it("rejects a foldable frame without a fold axis and an unknown frame", () => {
    const errors = errorsAfter((document) => {
      (devices(document)[1] as Mutable)["fold"] = "none";
      (devices(document)[2] as Mutable)["frame"] = "watch";
    });
    expect(errors).toContain("devices[1].fold: only a foldable frame has a fold axis, and it always has one");
    expect(errors.some((error) => error.startsWith("devices[2].frame: expected one of"))).toBe(true);
  });

  it("rejects a slot that names an unknown device or puts a device on a video slot", () => {
    const errors = errorsAfter((document) => {
      slotNamed(document, "apple.mac.screenshot")["device"] = "toaster";
      slotNamed(document, "apple.mac.app-preview")["device"] = "mac";
    });
    expect(errors.some((error) => error.endsWith(".device: unknown device toaster"))).toBe(true);
    expect(errors.some((error) => error.endsWith(".device: a app-preview slot cannot reference a device"))).toBe(true);
  });

  it("rejects a missing device list", () => {
    expect(errorsAfter((document) => {
      delete document["devices"];
    })).toContain("devices: expected an array");
  });
});
