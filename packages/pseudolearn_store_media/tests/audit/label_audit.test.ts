import { describe, expect, it } from "vitest";
import { auditLabels, characterCount } from "../../src/audit/label_audit.ts";
import { realCatalog, slot } from "../support/catalog.ts";

const catalog = realCatalog();
const screenshot = slot("microsoft.desktop.screenshot");

function messages(text: string, kind: "caption" | "title" = "caption", target = screenshot): readonly string[] {
  return auditLabels(catalog, target, [{ kind, language: "es", text }]).map((entry) => `${entry.rule}: ${entry.message}`);
}

describe("auditLabels", () => {
  it("accepts a caption of exactly 200 characters and a one-character caption", () => {
    expect(messages("a".repeat(200))).toEqual([]);
    expect(messages("a")).toEqual([]);
  });

  it("rejects 201 characters, an empty caption and a kind the slot does not take", () => {
    expect(messages("a".repeat(201))).toEqual(["TEXT-LENGTH: 201 characters exceed 200"]);
    expect(messages("   ")).toEqual(["TEXT-LENGTH: the caption is empty"]);
    expect(messages("Tráiler", "title")).toEqual(["TEXT-LENGTH: microsoft.desktop.screenshot takes no title"]);
  });

  it("counts characters, not UTF-16 units, so accents and emoji count once", () => {
    expect(characterCount("año")).toBe(3);
    expect(characterCount("é")).toBe(1);
    expect(characterCount("🙂")).toBe(1);
  });

  it("checks the trailer title at 255 and the store lexicon", () => {
    expect(messages("t".repeat(255), "title", slot("microsoft.trailer"))).toEqual([]);
    expect(messages("t".repeat(256), "title", slot("microsoft.trailer"))).toEqual(["TEXT-LENGTH: 256 characters exceed 255"]);
    expect(messages("También en iPhone")).toEqual(["TEXT-LEXICON: matches the other-platform rule of microsoft-store"]);
  });
});
