export type PngShape = { width: number; height: number; colorType: number; bitDepth?: number; transparency?: boolean };

export function pngBytes(shape: PngShape): Uint8Array {
  const signature = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];
  const header = chunk("IHDR", [
    ...uint32(shape.width), ...uint32(shape.height), shape.bitDepth ?? 8, shape.colorType, 0, 0, 0,
  ]);
  const transparency = shape.transparency ? chunk("tRNS", [0, 0, 0, 0, 0, 0]) : [];
  return new Uint8Array([...signature, ...header, ...transparency, ...chunk("IDAT", [0]), ...chunk("IEND", [])]);
}

function chunk(type: string, data: number[]): number[] {
  return [...uint32(data.length), ...[...type].map((letter) => letter.charCodeAt(0)), ...data, 0, 0, 0, 0];
}

function uint32(value: number): number[] {
  return [(value >>> 24) & 0xff, (value >>> 16) & 0xff, (value >>> 8) & 0xff, value & 0xff];
}
