import { describe, expect, it } from "vitest";
import { DebugSources } from "../../src/application/debug_sources";

function sources(text = "añ😀b\nsegunda\r\n") {
  const found = new DebugSources();
  found.snapshots.set(0, { sourceId: 0, path: "memfs:/root/a%20b.pseudo", text });
  return found;
}

describe("DebugSources", () => {
  it("maps core scalar columns to UTF-16 units and back", () => {
    const found = sources();
    expect(found.location(0, 1, 4)).toEqual([1, 5]);
    expect(found.coreLocation(0, 1, 5)).toEqual([1, 4]);
    expect(found.location(0, 2, 8)).toEqual([2, 8]);
  });

  it("honours zero-based clients and rejects columns inside a surrogate pair", () => {
    const found = sources();
    found.linesStartAtOne = false;
    found.columnsStartAtOne = false;
    expect(found.location(0, 1, 1)).toEqual([0, 0]);
    expect(found.coreLocation(0, 0, 0)).toEqual([1, 1]);
    expect(() => sources().coreLocation(0, 1, 4)).toThrow("Unicode boundary");
    expect(() => sources().coreLocation(0, 1, 0)).toThrow("invalid column");
  });

  it("finds snapshots by reference or by encoded and decoded path", () => {
    const found = sources();
    expect(found.identifier({ sourceReference: 1 })).toBe(0);
    expect(found.identifier({ path: "memfs:/root/a b.pseudo" })).toBe(0);
    expect(() => found.identifier({ sourceReference: 9 })).toThrow("unknown source reference");
    expect(() => found.identifier({ path: "memfs:/other.pseudo" })).toThrow("outside execution snapshot");
    expect(() => found.identifier(undefined)).toThrow("missing source");
    expect(found.describe(7)).toBeNull();
  });

  it("treats empty sources and missing lines as empty text", () => {
    const found = sources("");
    expect(found.location(0, 3, 1)).toEqual([3, 1]);
    expect(found.coreLocation(0, 1, 1)).toEqual([1, 1]);
  });
});
