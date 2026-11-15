import type { StereoSignal } from "./synthesizer.ts";

const HEADER_BYTES = 44;
const BYTES_PER_SAMPLE = 2;
const CHANNELS = 2;

export function encodeWav(signal: StereoSignal): Uint8Array {
  const frames = Math.min(signal.left.length, signal.right.length);
  const dataBytes = frames * CHANNELS * BYTES_PER_SAMPLE;
  const bytes = new Uint8Array(HEADER_BYTES + dataBytes);
  const view = new DataView(bytes.buffer);
  writeHeader(view, signal.sampleRate, dataBytes);
  for (let frame = 0; frame < frames; frame += 1) {
    const offset = HEADER_BYTES + frame * CHANNELS * BYTES_PER_SAMPLE;
    view.setInt16(offset, toPcm(signal.left[frame] ?? 0), true);
    view.setInt16(offset + BYTES_PER_SAMPLE, toPcm(signal.right[frame] ?? 0), true);
  }
  return bytes;
}

function writeHeader(view: DataView, sampleRate: number, dataBytes: number): void {
  writeAscii(view, 0, "RIFF");
  view.setUint32(4, HEADER_BYTES - 8 + dataBytes, true);
  writeAscii(view, 8, "WAVE");
  writeAscii(view, 12, "fmt ");
  view.setUint32(16, 16, true);
  view.setUint16(20, 1, true);
  view.setUint16(22, CHANNELS, true);
  view.setUint32(24, sampleRate, true);
  view.setUint32(28, sampleRate * CHANNELS * BYTES_PER_SAMPLE, true);
  view.setUint16(32, CHANNELS * BYTES_PER_SAMPLE, true);
  view.setUint16(34, 8 * BYTES_PER_SAMPLE, true);
  writeAscii(view, 36, "data");
  view.setUint32(40, dataBytes, true);
}

function writeAscii(view: DataView, offset: number, text: string): void {
  for (let index = 0; index < text.length; index += 1) {
    view.setUint8(offset + index, text.charCodeAt(index));
  }
}

function toPcm(sample: number): number {
  const clamped = Math.max(-1, Math.min(1, sample));
  return Math.round(clamped < 0 ? clamped * 0x8000 : clamped * 0x7fff);
}
