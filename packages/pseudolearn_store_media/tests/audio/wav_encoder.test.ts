import { describe, expect, it } from "vitest";
import { encodeWav } from "../../src/audio/wav_encoder.ts";

function ascii(bytes: Uint8Array, from: number, length: number): string {
  return String.fromCharCode(...bytes.subarray(from, from + length));
}

describe("encodeWav", () => {
  it("writes a 16-bit stereo PCM header", () => {
    const bytes = encodeWav({ sampleRate: 48000, left: new Float32Array(3), right: new Float32Array(3) });
    const view = new DataView(bytes.buffer);
    expect(ascii(bytes, 0, 4)).toBe("RIFF");
    expect(ascii(bytes, 8, 4)).toBe("WAVE");
    expect(view.getUint16(22, true)).toBe(2);
    expect(view.getUint32(24, true)).toBe(48000);
    expect(view.getUint16(34, true)).toBe(16);
    expect(view.getUint32(40, true)).toBe(12);
    expect(bytes.length).toBe(56);
  });

  it("interleaves channels and clamps out-of-range samples", () => {
    const bytes = encodeWav({ sampleRate: 8000, left: new Float32Array([1.5]), right: new Float32Array([-2]) });
    const view = new DataView(bytes.buffer);
    expect(view.getInt16(44, true)).toBe(32767);
    expect(view.getInt16(46, true)).toBe(-32768);
  });

  it("writes only a header for an empty signal", () => {
    expect(encodeWav({ sampleRate: 8000, left: new Float32Array(0), right: new Float32Array(0) }).length).toBe(44);
  });

  it("uses the shorter channel when lengths differ", () => {
    const bytes = encodeWav({ sampleRate: 8000, left: new Float32Array(4), right: new Float32Array(2) });
    expect(bytes.length).toBe(44 + 2 * 4);
  });
});
