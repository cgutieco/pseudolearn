import { open } from "node:fs/promises";
import type { Outcome } from "../pipeline/ports.ts";

export type BoxHeader = { readonly type: string; readonly offset: number; readonly size: number; readonly headerSize: number };
export type Mp4Layout = { readonly boxOrder: readonly string[]; readonly editLists: number };

const LARGE_HEADER = 16;
const SMALL_HEADER = 8;

export function boxAt(bytes: Uint8Array, offset: number, remaining: number): BoxHeader | null {
  if (offset + SMALL_HEADER > bytes.length) {
    return null;
  }
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  const declared = view.getUint32(offset);
  const type = String.fromCharCode(...bytes.subarray(offset + 4, offset + SMALL_HEADER));
  if (declared === 1) {
    return offset + LARGE_HEADER > bytes.length ? null
      : { type, offset, size: Number(view.getBigUint64(offset + SMALL_HEADER)), headerSize: LARGE_HEADER };
  }
  if (declared === 0) {
    return { type, offset, size: remaining, headerSize: SMALL_HEADER };
  }
  return declared < SMALL_HEADER ? null : { type, offset, size: declared, headerSize: SMALL_HEADER };
}

export function childBoxes(bytes: Uint8Array, start: number): readonly BoxHeader[] {
  const boxes: BoxHeader[] = [];
  let offset = start;
  while (offset < bytes.length) {
    const box = boxAt(bytes, offset, bytes.length - offset);
    if (!box || offset + box.size > bytes.length) {
      return boxes;
    }
    boxes.push(box);
    offset += box.size;
  }
  return boxes;
}

export function countEditLists(movie: Uint8Array): number {
  const header = boxAt(movie, 0, movie.length);
  if (!header || header.type !== "moov") {
    return 0;
  }
  return childBoxes(movie, header.headerSize).filter((box) => box.type === "trak").reduce((count, track) => {
    const bytes = movie.subarray(track.offset, track.offset + track.size);
    return count + childBoxes(bytes, track.headerSize).filter((box) => box.type === "edts").length;
  }, 0);
}

export async function readMp4Layout(path: string): Promise<Outcome<Mp4Layout>> {
  const handle = await open(path, "r").catch(() => null);
  if (!handle) {
    return { ok: false, error: `cannot open ${path}` };
  }
  try {
    const { size } = await handle.stat();
    const boxes: BoxHeader[] = [];
    for (let offset = 0; offset < size;) {
      const header = new Uint8Array(LARGE_HEADER);
      const { bytesRead } = await handle.read(header, 0, LARGE_HEADER, offset);
      const box = boxAt(header.subarray(0, bytesRead), 0, size - offset);
      if (!box) {
        break;
      }
      boxes.push({ ...box, offset });
      offset += box.size;
    }
    return { ok: true, value: { boxOrder: boxes.map((box) => box.type), editLists: await editListsIn(handle, boxes) } };
  } finally {
    await handle.close();
  }
}

async function editListsIn(handle: Awaited<ReturnType<typeof open>>, boxes: readonly BoxHeader[]): Promise<number> {
  const movie = boxes.find((box) => box.type === "moov");
  if (!movie) {
    return 0;
  }
  const bytes = new Uint8Array(movie.size);
  await handle.read(bytes, 0, movie.size, movie.offset);
  return countEditLists(bytes);
}
