export type PngHeader = {
  readonly width: number;
  readonly height: number;
  readonly bitDepth: number;
  readonly colorType: number;
};

export type PngReading = { readonly ok: true; readonly header: PngHeader } | { readonly ok: false; readonly reason: string };

const SIGNATURE = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];
const IHDR_END = 29;
const COLOR_TYPES_WITH_ALPHA = new Set([4, 6]);

export function readPngHeader(bytes: Uint8Array): PngReading {
  if (bytes.length < IHDR_END || SIGNATURE.some((value, index) => bytes[index] !== value)) {
    return { ok: false, reason: "not a PNG file" };
  }
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  const chunkType = String.fromCharCode(...bytes.subarray(12, 16));
  if (chunkType !== "IHDR") {
    return { ok: false, reason: "the first chunk is not IHDR" };
  }
  return {
    ok: true,
    header: {
      width: view.getUint32(16),
      height: view.getUint32(20),
      bitDepth: view.getUint8(24),
      colorType: view.getUint8(25),
    },
  };
}

export function hasAlphaChannel(header: PngHeader): boolean {
  return COLOR_TYPES_WITH_ALPHA.has(header.colorType);
}

export function hasTransparencyChunk(bytes: Uint8Array): boolean {
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  let offset = SIGNATURE.length;
  while (offset + 8 <= bytes.length) {
    const length = view.getUint32(offset);
    const type = String.fromCharCode(...bytes.subarray(offset + 4, offset + 8));
    if (type === "tRNS") {
      return true;
    }
    if (type === "IDAT" || type === "IEND") {
      return false;
    }
    offset += 12 + length;
  }
  return false;
}
