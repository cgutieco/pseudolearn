import { describe, expect, it } from "vitest";
import { auditContentRules } from "../../src/audit/content_rules_audit.ts";
import { buildAppIcon } from "../../src/compose/app_icon.ts";
import { BRAND_APP_ICON_SVG } from "../../src/compose/brand.generated.ts";
import { slot } from "../support/catalog.ts";

const icon = slot("google-play.app-icon");

describe("buildAppIcon", () => {
  it("draws the generated launcher icon full bleed at the slot size", () => {
    const composition = buildAppIcon("icon", icon);
    expect(composition.canvas).toEqual({ width: 512, height: 512 });
    expect(composition.html).toContain('<svg width="512" height="512" ');
    expect(composition.html).toContain(BRAND_APP_ICON_SVG.slice(BRAND_APP_ICON_SVG.indexOf("<title>")));
    expect(composition.texts).toEqual([]);
  });

  it("drops the XML declaration, which is not valid inside an HTML body", () => {
    expect(BRAND_APP_ICON_SVG.startsWith("<?xml")).toBe(true);
    expect(buildAppIcon("icon", icon).html).not.toContain("<?xml");
  });

  it("passes the content rules of a slot with none declared", () => {
    const composition = buildAppIcon("icon", icon);
    expect(auditContentRules("icon", { slot: icon, frames: composition.layout, texts: composition.texts, html: composition.html })).toEqual([]);
  });
});
