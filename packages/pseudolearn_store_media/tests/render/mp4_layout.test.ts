import { mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { describe, expect, it } from "vitest";
import { boxAt, childBoxes, countEditLists, readMp4Layout } from "../../src/render/mp4_layout.ts";

function box(type: string, ...children: readonly Uint8Array[]): Uint8Array {
  const payload = children.reduce((total, child) => total + child.length, 0);
  const bytes = new Uint8Array(8 + payload);
  new DataView(bytes.buffer).setUint32(0, bytes.length);
  bytes.set([...type].map((character) => character.charCodeAt(0)), 4);
  let offset = 8;
  for (const child of children) {
    bytes.set(child, offset);
    offset += child.length;
  }
  return bytes;
}

function joined(...parts: readonly Uint8Array[]): Uint8Array {
  return box("root", ...parts).subarray(8);
}

const movieWithEdits = box("moov", box("mvhd"), box("trak", box("tkhd"), box("edts", box("elst")), box("mdia")), box("trak", box("edts")));

describe("mp4 boxes", () => {
  it("reads small, large and open-ended headers", () => {
    expect(boxAt(box("ftyp"), 0, 8)).toEqual({ type: "ftyp", offset: 0, size: 8, headerSize: 8 });
    const large = new Uint8Array(16);
    new DataView(large.buffer).setUint32(0, 1);
    large.set([109, 100, 97, 116], 4);
    new DataView(large.buffer).setBigUint64(8, 4_000_000_000n);
    expect(boxAt(large, 0, 16)).toEqual({ type: "mdat", offset: 0, size: 4_000_000_000, headerSize: 16 });
    const open = box("mdat");
    new DataView(open.buffer).setUint32(0, 0);
    expect(boxAt(open, 0, 99)?.size).toBe(99);
  });

  it("rejects a truncated header and a size below the header", () => {
    expect(boxAt(new Uint8Array(4), 0, 4)).toBeNull();
    const broken = box("free");
    new DataView(broken.buffer).setUint32(0, 3);
    expect(boxAt(broken, 0, 8)).toBeNull();
  });

  it("lists children and stops at a box that overruns its parent", () => {
    expect(childBoxes(joined(box("ftyp"), box("moov")), 0).map((entry) => entry.type)).toEqual(["ftyp", "moov"]);
    const overrun = joined(box("ftyp"), box("moov"));
    new DataView(overrun.buffer, overrun.byteOffset).setUint32(8, 400);
    expect(childBoxes(overrun, 0).map((entry) => entry.type)).toEqual(["ftyp"]);
  });

  it("counts one edit list per track that has one", () => {
    expect(countEditLists(movieWithEdits)).toBe(2);
    expect(countEditLists(box("moov", box("trak", box("mdia"))))).toBe(0);
    expect(countEditLists(box("free"))).toBe(0);
  });
});

describe("readMp4Layout", () => {
  it("reads the top-level order and the edit lists of a file", async () => {
    const path = join(mkdtempSync(join(tmpdir(), "mp4-layout-")), "a.mp4");
    writeFileSync(path, joined(box("ftyp"), box("free"), box("mdat", box("data")), movieWithEdits));
    expect(await readMp4Layout(path)).toEqual({ ok: true, value: { boxOrder: ["ftyp", "free", "mdat", "moov"], editLists: 2 } });
  });

  it("reports a missing file", async () => {
    const outcome = await readMp4Layout(join(tmpdir(), "does-not-exist-mp4-layout.mp4"));
    expect(outcome.ok).toBe(false);
  });
});
