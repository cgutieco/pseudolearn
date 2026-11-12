import type { Projection } from "../contracts/worker_transport";
import { naturalOf } from "./debug_protocol";

export type OutputStream = "stdout" | "stderr";

export function errorRanges(value: Projection | undefined): Array<[number, number]> {
  if (!Array.isArray(value)) return [];
  const ranges: Array<[number, number]> = [];
  for (const range of value) {
    if (!Array.isArray(range)) continue;
    const start = naturalOf(range[0], -1);
    const end = naturalOf(range[1], -1);
    if (start >= 0 && end >= 0) ranges.push([start, end]);
  }
  return ranges;
}

export function outputSegments(output: string, printed: number, errors: Array<[number, number]>): Array<[OutputStream, string]> {
  const bytes = new TextEncoder().encode(output);
  const found: Array<[OutputStream, string]> = [];
  const push = (stream: OutputStream, start: number, end: number) => {
    if (end > start && start >= 0 && end <= bytes.length) found.push([stream, new TextDecoder().decode(bytes.subarray(start, end))]);
  };
  let cursor = printed;
  for (const [rangeStart, end] of errors) {
    const start = Math.max(rangeStart, cursor);
    if (end <= start) continue;
    push("stdout", cursor, start);
    push("stderr", start, end);
    cursor = end;
  }
  push("stdout", cursor, bytes.length);
  return found;
}

export function byteLength(output: string): number {
  return new TextEncoder().encode(output).length;
}
