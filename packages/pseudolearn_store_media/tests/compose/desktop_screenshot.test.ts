import { describe, expect, it } from "vitest";
import { auditContentRules } from "../../src/audit/content_rules_audit.ts";
import { auditSafeArea } from "../../src/audit/safe_area_audit.ts";
import { buildDesktopScreenshot, DESKTOP_PLATE_FILE } from "../../src/compose/desktop_screenshot.ts";
import { EDITORIAL_PALETTES } from "../../src/compose/editorial_palette.ts";
import { slot } from "../support/catalog.ts";

const desktop = slot("microsoft.desktop.screenshot");
const window = { x: 345.6, y: 120, width: 3148.8, height: 1771.2 };
const bars = [{ x: 0, y: 40, width: 200, height: 22, role: "keyword" as const }, { x: 240, y: 40, width: 90, height: 22, role: "name" as const }];

function build(rect: { x: number; y: number; width: number; height: number }) {
  return buildDesktopScreenshot({ id: "d-run-es", slot: desktop, palette: EDITORIAL_PALETTES.mint, window, bars, critical: { name: "diagram", rect } });
}

function audits(rect: { x: number; y: number; width: number; height: number }): readonly string[] {
  const composition = build(rect);
  return [
    ...auditContentRules(composition.id, { slot: desktop, frames: composition.layout, texts: composition.texts, html: composition.html }),
    ...auditSafeArea(composition.id, { slot: desktop, frames: composition.layout, profiles: [] }),
  ].map((entry) => `${entry.rule}: ${entry.message}`);
}

describe("buildDesktopScreenshot", () => {
  it("floats the real window over the chapter field with letterless code bars", () => {
    const composition = build({ x: 2000, y: 400, width: 800, height: 600 });
    expect(composition.html).toContain(`<img id="plate" src="${DESKTOP_PLATE_FILE}" alt="">`);
    expect(composition.html).toContain(`background: ${EDITORIAL_PALETTES.mint.field}`);
    expect(composition.html.match(/<rect /gu)).toHaveLength(2);
    expect(composition.texts).toEqual([]);
    expect(composition.layout[0]?.elements.map((element) => [element.name, element.content, element.essential])).toEqual([
      ["backdrop", "artwork", false], ["window", "app-interface", false], ["diagram", "app-interface", true]]);
  });

  it("passes the Microsoft rules when the critical piece sits in the top two thirds", () => {
    expect(audits({ x: 2000, y: 400, width: 800, height: 1040 })).toEqual([]);
  });

  it("fails both checks when the critical piece reaches the bottom third", () => {
    expect(audits({ x: 2000, y: 400, width: 800, height: 1100 })).toEqual([
      "MEDIA-CONTENT: diagram is essential but reaches the bottom third",
      "MEDIA-SAFE-AREA: diagram leaves the safe area at 0.00s",
    ]);
  });

  it("draws an empty backdrop when there are no bars", () => {
    const composition = buildDesktopScreenshot({ id: "x", slot: desktop, palette: EDITORIAL_PALETTES.deep, window, bars: [], critical: { name: "a", rect: window } });
    expect(composition.html).not.toContain("<rect ");
  });
});
