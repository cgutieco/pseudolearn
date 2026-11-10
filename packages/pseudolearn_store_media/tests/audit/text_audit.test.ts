import { describe, expect, it } from "vitest";
import { auditContrast, auditLexicon, contrastRatio } from "../../src/audit/text_audit.ts";
import { realCatalog } from "../support/catalog.ts";

const catalog = realCatalog();

function lexiconIds(store: "app-store" | "microsoft-store", text: string): readonly string[] {
  return auditLexicon(catalog, store, [text]).map((entry) => entry.message.split(" ")[2] ?? "");
}

describe("auditLexicon", () => {
  it("accepts honest product copy in both languages", () => {
    expect(auditLexicon(catalog, "app-store", ["Tu algoritmo, en código y en diagrama", "Watch every variable change"])).toEqual([]);
  });

  it("does not confuse the Spanish verb sale with a sale", () => {
    expect(auditLexicon(catalog, "app-store", ["El programa sale del bucle"])).toEqual([]);
  });

  it("rejects prices, links, copyright and unverifiable claims everywhere", () => {
    expect(lexiconIds("app-store", "Solo $4.99")).toEqual(["price"]);
    expect(lexiconIds("microsoft-store", "Visita www.pseudolearn.app")).toEqual(["url"]);
    expect(lexiconIds("app-store", "© PseudoLearn")).toEqual(["copyright"]);
    expect(lexiconIds("app-store", "La mejor app #1")).toEqual(["unverifiable-claim"]);
  });

  it("rejects the other store's platforms in each store", () => {
    expect(lexiconIds("app-store", "También en Windows")).toEqual(["other-platform"]);
    expect(lexiconIds("microsoft-store", "Also on iPhone")).toEqual(["other-platform"]);
    expect(lexiconIds("microsoft-store", "También en Windows")).toEqual([]);
  });

  it("rejects Apple recognitions in Apple assets and age ratings in Microsoft assets", () => {
    expect(lexiconIds("app-store", "App del día")).toEqual(["apple-recognition"]);
    expect(lexiconIds("microsoft-store", "PEGI 3")).toEqual(["age-rating"]);
  });

  it("rejects pre-release labels and calls to action carried over from the retired app copy rules", () => {
    expect(lexiconIds("app-store", "Ya en beta")).toEqual(["pre-release"]);
    expect(lexiconIds("app-store", "Próximamente en tu iPad")).toEqual(["pre-release"]);
    expect(lexiconIds("app-store", "Descárgala ahora")).toEqual(["call-to-action"]);
    expect(lexiconIds("microsoft-store", "Download now")).toEqual(["call-to-action"]);
    expect(lexiconIds("app-store", "Ahora es un lenguaje de verdad")).toEqual([]);
  });

  it("accepts an empty text list", () => {
    expect(auditLexicon(catalog, "app-store", [])).toEqual([]);
  });
});

describe("contrast", () => {
  it("computes the WCAG ratio", () => {
    expect(contrastRatio("#000000", "#FFFFFF")).toBeCloseTo(21, 5);
    expect(contrastRatio("#FFFFFF", "#FFFFFF")).toBeCloseTo(1, 5);
  });

  it("accepts brand ink on the deep ground and rejects a faint grey", () => {
    expect(auditContrast([{ role: "headline", foreground: "#FFFFFF", background: "#0F4346" }])).toEqual([]);
    expect(auditContrast([{ role: "caption", foreground: "#9AA5A6", background: "#FFFFFF" }]).map((entry) => entry.rule))
      .toEqual(["TEXT-CONTRAST"]);
  });

  it("rejects a colour it cannot read", () => {
    expect(auditContrast([{ role: "broken", foreground: "white", background: "#000000" }])).toHaveLength(1);
  });
});
