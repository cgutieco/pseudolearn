import { describe, expect, it } from "vitest";
import { JsonReader } from "../../src/catalog/json_reader.ts";
import { parseCaptions, parsePins } from "../../src/story/preview_overlays.ts";

const text = { es: "Corre *paso a paso.*", en: "Runs *step by step.*" };

describe("parseCaptions", () => {
  it("reads the role, the marked text and the window", () => {
    const reader = new JsonReader();
    expect(parseCaptions(reader, [{ role: "note", text, from: 1, to: 4 }], "captions")).toEqual([
      { role: "note", text, anchor: null, fromSeconds: 1, toSeconds: 4 },
    ]);
    expect(reader.errors).toEqual([]);
  });

  it("rejects an unknown role, unpaired marks, a reversed window and a missing language", () => {
    const reader = new JsonReader();
    parseCaptions(reader, [{ role: "price", text: { es: "*abierto", en: "x" }, from: 4, to: 1 }, { role: "note", text: { es: "x" }, from: 0, to: 1 }], "captions");
    expect(reader.errors.map((error) => error.path)).toEqual([
      "captions[0].role", "captions[0].text.es", "captions[0].to", "captions[1].text.en",
    ]);
  });

  it("reads an anchor and rejects one that is not an edge", () => {
    const reader = new JsonReader();
    const [caption] = parseCaptions(reader, [{ role: "headline", text, anchor: "bottom", from: 0, to: 3 }, { role: "note", text, anchor: "middle", from: 0, to: 3 }], "captions");
    expect(caption?.anchor).toBe("bottom");
    expect(reader.errors.map((error) => error.path)).toEqual(["captions[1].anchor"]);
  });

  it("accepts no captions", () => {
    expect(parseCaptions(new JsonReader(), [], "captions")).toEqual([]);
  });
});

describe("parsePins", () => {
  it("reads the focus, the relative point and the note", () => {
    const reader = new JsonReader();
    const [pin] = parsePins(reader, [{ focus: "trace", pin: { x: 0, y: 1 }, note: text, from: 0, to: 3 }], "pins");
    expect(pin).toEqual({ focus: "trace", pin: { x: 0, y: 1 }, note: text, fromSeconds: 0, toSeconds: 3 });
    expect(reader.errors).toEqual([]);
  });

  it("rejects a point outside the focus rectangle and unknown keys", () => {
    const reader = new JsonReader();
    parsePins(reader, [{ focus: "trace", pin: { x: 1.5, y: 0, z: 1 }, note: text, from: 0, to: 3 }], "pins");
    expect(reader.errors.map((error) => error.path)).toEqual(["pins[0].pin.z", "pins[0].pin.x"]);
  });
});
