import { describe, expect, it } from "vitest";
import { auditContentRules } from "../../src/audit/content_rules_audit.ts";
import type { PlacedElement } from "../../src/layout/safe_area_check.ts";
import { slot } from "../support/catalog.ts";

const hero = slot("microsoft.hero-art");
const screenshot = slot("microsoft.desktop.screenshot");
const art: PlacedElement = { name: "lens", rect: { x: 400, y: 300, width: 3000, height: 1000 }, essential: true, content: "artwork" };
const plate: PlacedElement = { name: "plate", rect: { x: 0, y: 0, width: 3840, height: 2160 }, essential: false, content: "app-interface" };

function messages(target: typeof hero, elements: readonly PlacedElement[], extra: { texts?: readonly string[]; html?: string } = {}): readonly string[] {
  return auditContentRules("piece", { slot: target, frames: [{ timeSeconds: 0, elements }], texts: extra.texts ?? [], html: extra.html ?? "<svg></svg>" })
    .map((entry) => `${entry.rule}: ${entry.message}`);
}

describe("auditContentRules on the hero art", () => {
  it("accepts artwork without text inside the top two thirds", () => {
    expect(messages(hero, [art])).toEqual([]);
  });

  it("rejects interface, added text, declared texts and visible markup text", () => {
    expect(messages(hero, [art, plate])).toEqual(["MEDIA-CONTENT: plate is app-interface, which no-interface forbids"]);
    expect(messages(hero, [art], { texts: ["si"], html: "<svg><text>si</text></svg>" })).toEqual([
      "MEDIA-CONTENT: declares texts \"si\", which no-text forbids",
      "MEDIA-CONTENT: the markup shows \"si\", which no-text forbids",
    ]);
    expect(messages(hero, [{ ...art, name: "title", content: "added-text" }])).toEqual(["MEDIA-CONTENT: title is added-text, which no-text forbids"]);
  });

  it("rejects an element that does not declare its content", () => {
    expect(messages(hero, [{ name: "lens", rect: art.rect, essential: true }])).toEqual(["MEDIA-CONTENT: lens declares no content kind"]);
  });

  it("rejects an essential element that reaches the bottom third, at the exact edge", () => {
    expect(messages(hero, [{ ...art, rect: { x: 400, y: 440, width: 3000, height: 1000 } }])).toEqual([]);
    expect(messages(hero, [{ ...art, rect: { x: 400, y: 441, width: 3000, height: 1000 } }])).toEqual(["MEDIA-CONTENT: lens is essential but reaches the bottom third"]);
    expect(messages(hero, [{ ...art, essential: false, rect: { x: 0, y: 1500, width: 10, height: 600 } }])).toEqual([]);
  });
});

describe("auditContentRules on the desktop screenshot", () => {
  it("accepts the bare plate", () => {
    expect(messages(screenshot, [plate], { html: `<img src="plate.png">` })).toEqual([]);
  });

  it("rejects an added logo or caption on the image", () => {
    expect(messages(screenshot, [plate, { ...art, name: "logo", content: "added-mark", essential: false }])).toEqual(["MEDIA-CONTENT: logo is added-mark, which no-added-text forbids"]);
    expect(messages(screenshot, [plate], { html: "<img><p>Aprende</p>" })).toEqual(["MEDIA-CONTENT: the markup shows \"Aprende\", which no-added-text forbids"]);
  });

  it("leaves slots without content rules alone", () => {
    expect(messages(slot("microsoft.trailer"), [{ name: "x", rect: art.rect, essential: false }], { texts: ["Hola"], html: "<p>Hola</p>" })).toEqual([]);
  });
});
