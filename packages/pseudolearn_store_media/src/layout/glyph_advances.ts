export type GlyphAdvances = {
  readonly unitsPerEm: number;
  readonly advanceOf: (codePoint: number) => number | null;
};

export type FontReading = { readonly ok: true; readonly advances: GlyphAdvances } | { readonly ok: false; readonly reason: string };

type Tables = ReadonlyMap<string, number>;

const TABLE_RECORD_SIZE = 16;
const UNICODE_BMP_SUBTABLES = [[3, 1], [0, 3], [0, 4]] as const;

export function readGlyphAdvances(bytes: Uint8Array): FontReading {
  if (bytes.length < 12) {
    return { ok: false, reason: "the font file is truncated" };
  }
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  const tables = tableOffsets(view);
  const [head, hhea, hmtx, cmap] = ["head", "hhea", "hmtx", "cmap"].map((tag) => tables.get(tag));
  if (head === undefined || hhea === undefined || hmtx === undefined || cmap === undefined) {
    return { ok: false, reason: "the font lacks head, hhea, hmtx or cmap" };
  }
  const glyphOf = format4Lookup(view, cmap);
  if (!glyphOf) {
    return { ok: false, reason: "the font has no Unicode format 4 character map" };
  }
  const metricCount = view.getUint16(hhea + 34);
  const advanceOfGlyph = (glyph: number): number => view.getUint16(hmtx + 4 * Math.min(glyph, metricCount - 1));
  return {
    ok: true,
    advances: {
      unitsPerEm: view.getUint16(head + 18),
      advanceOf: (codePoint) => {
        const glyph = glyphOf(codePoint);
        return glyph === 0 ? null : advanceOfGlyph(glyph);
      },
    },
  };
}

export function textWidth(advances: GlyphAdvances, text: string, fontSize: number): number {
  const fallback = advances.advanceOf(0x20) ?? advances.unitsPerEm / 2;
  const units = [...text].reduce((total, letter) => total + (advances.advanceOf(letter.codePointAt(0) ?? 0) ?? fallback), 0);
  return (units * fontSize) / advances.unitsPerEm;
}

function tableOffsets(view: DataView): Tables {
  const count = view.getUint16(4);
  const tables = new Map<string, number>();
  for (let index = 0; index < count; index += 1) {
    const record = 12 + index * TABLE_RECORD_SIZE;
    if (record + TABLE_RECORD_SIZE > view.byteLength) {
      break;
    }
    const tag = String.fromCharCode(...[0, 1, 2, 3].map((offset) => view.getUint8(record + offset)));
    tables.set(tag, view.getUint32(record + 8));
  }
  return tables;
}

function format4Lookup(view: DataView, cmap: number): ((codePoint: number) => number) | null {
  const count = view.getUint16(cmap + 2);
  const records = Array.from({ length: count }, (_, index) => ({
    platform: view.getUint16(cmap + 4 + index * 8),
    encoding: view.getUint16(cmap + 6 + index * 8),
    offset: cmap + view.getUint32(cmap + 8 + index * 8),
  }));
  const chosen = UNICODE_BMP_SUBTABLES
    .map(([platform, encoding]) => records.find((record) => record.platform === platform && record.encoding === encoding))
    .find((record) => record !== undefined && view.getUint16(record.offset) === 4);
  return chosen ? (codePoint) => format4Glyph(view, chosen.offset, codePoint) : null;
}

function format4Glyph(view: DataView, subtable: number, codePoint: number): number {
  const segments = view.getUint16(subtable + 6) / 2;
  const ends = subtable + 14;
  const starts = ends + segments * 2 + 2;
  const deltas = starts + segments * 2;
  const rangeOffsets = deltas + segments * 2;
  for (let segment = 0; segment < segments; segment += 1) {
    const end = view.getUint16(ends + segment * 2);
    const start = view.getUint16(starts + segment * 2);
    if (codePoint > end || codePoint < start) {
      continue;
    }
    const delta = view.getInt16(deltas + segment * 2);
    const rangeAddress = rangeOffsets + segment * 2;
    const rangeOffset = view.getUint16(rangeAddress);
    if (rangeOffset === 0) {
      return (codePoint + delta) & 0xffff;
    }
    const glyph = view.getUint16(rangeAddress + rangeOffset + 2 * (codePoint - start));
    return glyph === 0 ? 0 : (glyph + delta) & 0xffff;
  }
  return 0;
}
