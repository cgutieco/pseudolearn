export class SignedDataError extends Error {}

export interface DerNode {
  readonly tag: number;
  readonly start: number;
  readonly contentStart: number;
  readonly end: number;
}

const longFormFlag = 0x80;
const lengthBitsMask = 0x7f;
const maxLengthBytes = 4;
const utcTimeTag = 0x17;

export function readNode(bytes: Uint8Array, offset: number): DerNode {
  const tag = bytes[offset];
  const first = bytes[offset + 1];
  if (tag === undefined || first === undefined) throw new SignedDataError("der_truncated");
  let cursor = offset + 2;
  let length = first;
  if ((first & longFormFlag) !== 0) {
    const count = first & lengthBitsMask;
    if (count === 0 || count > maxLengthBytes) throw new SignedDataError("der_length");
    length = 0;
    for (let index = 0; index < count; index++) {
      const byte = bytes[cursor++];
      if (byte === undefined) throw new SignedDataError("der_truncated");
      length = length * 256 + byte;
    }
  }
  const end = cursor + length;
  if (end > bytes.length) throw new SignedDataError("der_truncated");
  return { tag, start: offset, contentStart: cursor, end };
}

export function childrenOf(bytes: Uint8Array, node: DerNode): DerNode[] {
  const result: DerNode[] = [];
  let offset = node.contentStart;
  while (offset < node.end) {
    const child = readNode(bytes, offset);
    result.push(child);
    offset = child.end;
  }
  return result;
}

export function objectIdentifierOf(bytes: Uint8Array, node: DerNode): string {
  const content = bytes.subarray(node.contentStart, node.end);
  const first = content[0] ?? 0;
  const parts = [Math.floor(first / 40), first % 40];
  let value = 0;
  for (let index = 1; index < content.length; index++) {
    const byte = content[index] ?? 0;
    value = value * 128 + (byte & lengthBitsMask);
    if ((byte & longFormFlag) === 0) {
      parts.push(value);
      value = 0;
    }
  }
  return parts.join(".");
}

export function encodedObjectIdentifier(dotted: string): Uint8Array {
  const parts = dotted.split(".").map(Number);
  const body: number[] = [(parts[0] ?? 0) * 40 + (parts[1] ?? 0)];
  for (const part of parts.slice(2)) {
    const chunk: number[] = [part & lengthBitsMask];
    let value = Math.floor(part / 128);
    while (value > 0) {
      chunk.unshift((value & lengthBitsMask) | longFormFlag);
      value = Math.floor(value / 128);
    }
    body.push(...chunk);
  }
  return Uint8Array.from([0x06, body.length, ...body]);
}

export function timeOf(bytes: Uint8Array, node: DerNode): number {
  const text = new TextDecoder().decode(bytes.subarray(node.contentStart, node.end));
  const century = Number(text.slice(0, 2)) >= 50 ? "19" : "20";
  const full = node.tag === utcTimeTag ? `${century}${text}` : text;
  const match = /^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})Z$/.exec(full);
  if (match === null) throw new SignedDataError("der_time");
  const [year, month, day, hour, minute, second] = match.slice(1).map(Number);
  return Date.UTC(year, month - 1, day, hour, minute, second);
}

export function containsBytes(haystack: Uint8Array, needle: Uint8Array): boolean {
  for (let start = 0; start <= haystack.length - needle.length; start++) {
    if (needle.every((byte, index) => haystack[start + index] === byte)) return true;
  }
  return false;
}
