import { describe, expect, it } from "vitest";
import { parseCatalog } from "../../src/catalog/parse_catalog.ts";
import { lexiconDocument, slot, slotsDocument } from "../support/catalog.ts";

type Mutable = Record<string, unknown>;

function errorsWithSlot(id: string, change: (entry: Mutable) => void): readonly string[] {
  const document = slotsDocument();
  const entries = document["slots"] as Mutable[];
  const index = entries.findIndex((entry) => entry["id"] === id);
  change(entries[index] as Mutable);
  const parsed = parseCatalog(document, lexiconDocument());
  return parsed.ok ? [] : parsed.errors.map((error) => `${error.path}: ${error.message}`).map((text) => text.replace(`slots[${index}]`, id));
}

describe("label limits", () => {
  it("caps the Microsoft screenshot caption at 200 characters and the trailer title at 255", () => {
    expect(slot("microsoft.desktop.screenshot").labelLimits).toEqual({ caption: 200 });
    expect(slot("microsoft.trailer").labelLimits).toEqual({ title: 255 });
  });

  it("leaves a slot without labels empty", () => {
    expect(slot("apple.mac.screenshot").labelLimits).toEqual({});
  });

  it("rejects an unknown label kind and a limit of zero", () => {
    const errors = errorsWithSlot("microsoft.trailer", (entry) => {
      entry["labelLimits"] = { title: 0, subtitle: 40 };
    });
    expect(errors).toContain("microsoft.trailer.labelLimits.subtitle: unknown key");
    expect(errors.some((error) => error.startsWith("microsoft.trailer.labelLimits.title:"))).toBe(true);
  });
});

describe("critical-top-two-thirds", () => {
  it("keeps every Microsoft still that carries the rule above two thirds of the height", () => {
    for (const id of ["microsoft.desktop.screenshot", "microsoft.hero-art", "microsoft.poster-art", "microsoft.box-art"]) {
      const area = slot(id).safeArea;
      expect(slot(id).rules).toContain("critical-top-two-thirds");
      expect(area.y + area.height).toBeLessThanOrEqual(2 / 3 + 1e-4);
    }
  });

  it("centres the hero art away from every edge", () => {
    expect(slot("microsoft.hero-art").safeArea).toEqual({ x: 0.1, y: 0.1, width: 0.8, height: 0.566667 });
    expect(slot("microsoft.hero-art").rules).toEqual(["critical-top-two-thirds", "key-info-centered", "no-text", "no-interface"]);
  });

  it("rejects a safe area that reaches the bottom third", () => {
    const errors = errorsWithSlot("microsoft.hero-art", (entry) => {
      entry["safeArea"] = { x: 0.1, y: 0.1, width: 0.8, height: 0.8 };
    });
    expect(errors).toEqual(["microsoft.hero-art.safeArea: a critical-top-two-thirds slot keeps its safe area inside the top two thirds"]);
  });
});

describe("the Windows desktop screenshot", () => {
  it("records its plates on a frameless desktop that fills the 4K canvas", () => {
    const desktop = slot("microsoft.desktop.screenshot");
    expect(desktop.device).toMatchObject({ id: "windows-desktop", frame: "none", cornerRadius: 0 });
    expect((desktop.device?.logicalWidth ?? 0) * (desktop.device?.plateScale ?? 0)).toBe(desktop.width);
    expect((desktop.device?.logicalHeight ?? 0) * (desktop.device?.plateScale ?? 0)).toBe(desktop.height);
  });
});

describe("seamless-loop", () => {
  it("asks only the App Store header and search videos to loop", () => {
    const looping = ["apple.header.video", "apple.search.video"];
    for (const id of [...looping, "microsoft.trailer", "apple.mac.app-preview"]) {
      expect(slot(id).rules.includes("seamless-loop")).toBe(looping.includes(id));
    }
  });
});
