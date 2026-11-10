import { describe, expect, it } from "vitest";
import { parseCatalog } from "../../src/catalog/parse_catalog.ts";
import { lexiconDocument, realCatalog, slotsDocument } from "../support/catalog.ts";

type Mutable = Record<string, unknown>;

function withFirstSlot(change: (slot: Mutable) => void): Mutable {
  const document = slotsDocument();
  const slots = document["slots"] as Mutable[];
  change(slots[0] as Mutable);
  return document;
}

function withVideoSlot(id: string, change: (video: Mutable) => void): Mutable {
  const document = slotsDocument();
  const target = (document["slots"] as Mutable[]).find((entry) => entry["id"] === id) as Mutable;
  change(target["video"] as Mutable);
  return document;
}

function errorsOf(slots: unknown, lexicon: unknown = lexiconDocument()): readonly string[] {
  const parsed = parseCatalog(slots, lexicon);
  return parsed.ok ? [] : parsed.errors.map((error) => `${error.path}: ${error.message}`);
}

describe("parseCatalog", () => {
  it("accepts the catalog the package ships", () => {
    const catalog = realCatalog();
    expect(catalog.slots).toHaveLength(16);
    expect(catalog.localesByLanguage["app-store"].es).toEqual(["es-MX"]);
    expect(catalog.localesByLanguage["microsoft-store"].es).toEqual(["es-ES"]);
    expect(catalog.loudness.integratedLufs).toBe(-16);
  });

  it("keeps the official safe area of the header template", () => {
    const header = realCatalog().slots.find((slot) => slot.id === "apple.header.video");
    expect(header?.safeArea.x).toBeCloseTo(1097 / 3840, 5);
    expect(header?.safeArea.height).toBeCloseTo(661 / 1646, 5);
  });

  it("fills defaults for a still slot", () => {
    const still = realCatalog().slots.find((slot) => slot.id === "microsoft.trailer-thumbnail");
    expect(still?.video).toBeNull();
    expect(still?.device).toBeNull();
    expect(still?.safeArea).toEqual({ x: 0, y: 0, width: 1, height: 1 });
    expect(realCatalog().slots.find((slot) => slot.id === "apple.mac.screenshot")?.maxBytes).toBe(524_288_000);
  });

});

describe("parseCatalog rejections", () => {
  it("rejects a document that is not an object", () => {
    expect(errorsOf(null)).toContain("$: expected an object");
  });

  it("rejects unknown keys and unknown kinds", () => {
    const errors = errorsOf(withFirstSlot((slot) => {
      slot["colour"] = "red";
      slot["kind"] = "billboard";
    }));
    expect(errors.some((error) => error.endsWith("colour: unknown key"))).toBe(true);
    expect(errors.some((error) => error.includes("kind: expected one of"))).toBe(true);
  });

  it("rejects a video kind without video traits and a still kind with them", () => {
    const document = slotsDocument();
    const slots = document["slots"] as Mutable[];
    const header = slots.find((entry) => entry["id"] === "apple.header.video") as Mutable;
    const still = slots[0] as Mutable;
    still["video"] = header["video"];
    delete header["video"];
    const errors = errorsOf(document);
    expect(errors.some((error) => error.includes("a header-video slot needs video traits"))).toBe(true);
    expect(errors.some((error) => error.includes("a screenshot slot cannot have video traits"))).toBe(true);
  });

});

describe("parseCatalog video traits", () => {
  it("rejects an fps outside the accepted list and an inverted duration", () => {
    const errors = errorsOf(withVideoSlot("microsoft.trailer", (video) => {
      video["fps"] = 24;
      video["duration"] = { min: 30, max: 15 };
    }));
    expect(errors).toContain("slots[12].video.fps: must be one of acceptedFps");
    expect(errors).toContain("slots[12].video.duration: min must not exceed max");
  });

  it("rejects a reference to a codec profile that does not exist", () => {
    const errors = errorsOf(withVideoSlot("microsoft.trailer", (video) => {
      video["codecProfile"] = "vhs";
    }));
    expect(errors).toContain("slots[12].video.codecProfile: unknown codec profile vhs");
  });

});

describe("parseCatalog geometry and references", () => {
  it("rejects a safe area that leaves the canvas or is empty", () => {
    const outside = errorsOf(withFirstSlot((slot) => {
      slot["safeArea"] = { x: 0.6, y: 0, width: 0.5, height: 1 };
    }));
    const empty = errorsOf(withFirstSlot((slot) => {
      slot["safeArea"] = { x: 0, y: 0, width: 0, height: 1 };
    }));
    expect(outside).toContain("slots[0].safeArea: must be a non-empty rectangle inside the canvas");
    expect(empty).toContain("slots[0].safeArea: must be a non-empty rectangle inside the canvas");
  });

  it("rejects duplicate slot identities", () => {
    const document = slotsDocument();
    const slots = document["slots"] as Mutable[];
    slots.push({ ...(slots[0] as Mutable) });
    expect(errorsOf(document)).toContain("slots: duplicate slot id apple.iphone.screenshot");
  });

  it("rejects an invalid lexicon pattern", () => {
    const lexicon = lexiconDocument();
    lexicon["shared"] = [{ id: "broken", pattern: "(" }];
    expect(errorsOf(slotsDocument(), lexicon)).toContain("lexicon.shared[0]: pattern is not a valid regular expression");
  });

});
