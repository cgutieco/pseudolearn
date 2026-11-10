import { describe, expect, it } from "vitest";
import { placeBrandCard } from "../../src/layout/brand_card_layout.ts";

const narrow = (text: string, size: number): number => text.length * size * 0.5;
const phone = { width: 886, height: 1920 };
const insets = { top: 124, right: 0, bottom: 68, left: 0 };

describe("placeBrandCard", () => {
  it("centres the opening card and keeps the interface around it visible", () => {
    const placed = placeBrandCard({ canvas: phone, insets, kind: "opening", lockupAspect: 4, lines: [] }, narrow);
    expect(placed.card.y + placed.card.height / 2).toBeCloseTo(960);
    expect(placed.card.x + placed.card.width / 2).toBeCloseTo(443);
    expect(placed.text).toBeNull();
    expect(placed.coverFraction).toBeLessThan(0.15);
  });

  it("puts the closing card above the bottom inset with the disclosure under the logo", () => {
    const placed = placeBrandCard({ canvas: phone, insets, kind: "closing", lockupAspect: 4, lines: ["Nodo requiere sesión y suscripción."] }, narrow);
    expect(placed.card.y + placed.card.height).toBeLessThanOrEqual(1920 - 68);
    expect(placed.text?.y ?? 0).toBeGreaterThan(placed.lockup.y + placed.lockup.height);
    expect(placed.fit?.fits).toBe(true);
  });

  it("limits the card by height on a landscape Mac canvas", () => {
    const placed = placeBrandCard({ canvas: { width: 1920, height: 1080 }, insets: { top: 0, right: 0, bottom: 0, left: 0 }, kind: "opening",
      lockupAspect: 4, lines: [] }, narrow);
    expect(placed.card.width).toBeCloseTo(972);
  });

  it("reports a disclosure that cannot fit at the smallest size", () => {
    const placed = placeBrandCard({ canvas: phone, insets, kind: "closing", lockupAspect: 4, lines: ["x".repeat(300)] }, narrow);
    expect(placed.fit?.fits).toBe(false);
  });
});
