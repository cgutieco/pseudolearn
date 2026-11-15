import type { PixelRect, Size } from "./pixel_rect.ts";

export const WINDOW_SCALE = 0.82;
export const WINDOW_TOP = 120;
export const WINDOW_RADIUS = 26;

export type RegionWithin = { readonly x: number; readonly y: number; readonly width: number; readonly height: number };

export function windowRect(canvas: Size, plate: Size): PixelRect {
  const width = plate.width * WINDOW_SCALE;
  const height = plate.height * WINDOW_SCALE;
  return { x: (canvas.width - width) / 2, y: WINDOW_TOP, width, height };
}

export function projectRegion(focus: PixelRect, region: RegionWithin, window: { rect: PixelRect; plate: Size }): PixelRect {
  const scale = window.rect.width / window.plate.width;
  return {
    x: window.rect.x + (focus.x + focus.width * region.x) * scale,
    y: window.rect.y + (focus.y + focus.height * region.y) * scale,
    width: focus.width * region.width * scale,
    height: focus.height * region.height * scale,
  };
}
