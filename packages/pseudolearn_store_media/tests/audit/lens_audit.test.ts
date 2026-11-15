import { describe, expect, it } from "vitest";
import { auditLensLabels, auditLensRows } from "../../src/audit/lens_audit.ts";
import { lensLayout } from "../../src/layout/lens_layout.ts";
import { slot } from "../support/catalog.ts";
import { SIMPLE_MEASURE } from "../support/lens.ts";

const layout = lensLayout({
  slot: slot("apple.header.video"),
  entries: [{ text: "Leer temperatura;", form: "box" }, { text: "FinMientras", form: "dot" }],
  rhythm: { statementsPerRow: 2, statementStride: 1, phaseStride: 0.5 },
  measure: SIMPLE_MEASURE,
});

describe("auditLensLabels", () => {
  it("accepts labels that fit their node and skips the dot", () => {
    expect(auditLensLabels("lens", layout, SIMPLE_MEASURE.sans)).toEqual([]);
  });

  it("rejects a label wider than its node, once per statement", () => {
    const wide = (text: string, size: number) => text.length * size * 2;
    const findings = auditLensLabels("lens", layout, wide);
    expect(findings).toHaveLength(1);
    expect(findings[0]?.rule).toBe("TEXT-FIT");
    expect(findings[0]?.message).toContain("Leer temperatura;");
  });
});

describe("auditLensRows", () => {
  it("accepts a lens crossed by rows and rejects an empty one", () => {
    expect(auditLensRows("lens", layout)).toEqual([]);
    const empty = { ...layout, rows: layout.rows.map((row) => ({ ...row, inLens: false })) };
    expect(auditLensRows("lens", empty).map((entry) => entry.rule)).toEqual(["MEDIA-SAFE-AREA"]);
  });
});
