import { describe, expect, it } from "vitest";
import { JsonReader } from "../../src/catalog/json_reader.ts";
import { parseBrandCards, parseDisclosure } from "../../src/story/preview_brand.ts";

describe("parseBrandCards", () => {
  it("reads how long the opening and closing cards last, and nothing when absent", () => {
    const reader = new JsonReader();
    expect(parseBrandCards(reader, { opening: 2.3, closing: 3.3 }, "brand")).toEqual({ openingSeconds: 2.3, closingSeconds: 3.3 });
    expect(parseBrandCards(reader, undefined, "brand")).toBeNull();
    expect(reader.errors).toEqual([]);
  });

  it("rejects unknown keys and cards longer than ten seconds", () => {
    const reader = new JsonReader();
    parseBrandCards(reader, { opening: 11, closing: 1, middle: 2 }, "brand");
    expect(reader.errors.map((error) => error.path)).toEqual(["brand.middle", "brand.opening"]);
  });
});

describe("parseDisclosure", () => {
  it("reads the plates that need a disclosure and its text in both languages", () => {
    const reader = new JsonReader();
    const disclosure = parseDisclosure(reader, { plates: ["preview-nodo"], text: { es: "Requiere sesión.", en: "Needs sign-in." } }, "disclosure");
    expect(disclosure).toEqual({ plates: ["preview-nodo"], text: { es: "Requiere sesión.", en: "Needs sign-in." } });
    expect(parseDisclosure(reader, undefined, "disclosure")).toBeNull();
  });

  it("rejects a missing language and an empty plate name", () => {
    const reader = new JsonReader();
    parseDisclosure(reader, { plates: [""], text: { es: "Requiere sesión." } }, "disclosure");
    expect(reader.errors.map((error) => error.path)).toEqual(["disclosure.plates[0]", "disclosure.text.en"]);
  });
});
