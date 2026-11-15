import type { FakeToolbox } from "./fake_toolbox.ts";
import { pngBytes } from "./png.ts";

export const MAC_NODO = "plates/chapter-nodo/mac/dark/es";

export function timelineBytes(focus: readonly { key: string; x: number; y: number; width: number; height: number }[]): Uint8Array {
  return new TextEncoder().encode(JSON.stringify({
    scene: "chapter-nodo", language: "es", fps: 30, pixelWidth: 2880, pixelHeight: 1800,
    frames: [{ index: 0, file: "frame_000001.png", focus }], events: [{ frame: 0, kind: "completion" }],
  }));
}

export function recordMacNodo(toolbox: FakeToolbox, focusKey = "verified-code"): void {
  toolbox.written.set(`${MAC_NODO}/frame_000001.png`, pngBytes({ width: 2880, height: 1800, colorType: 2 }));
  toolbox.written.set(`${MAC_NODO}/timeline.json`, timelineBytes([{ key: focusKey, x: 2000, y: 600, width: 700, height: 800 }]));
}
