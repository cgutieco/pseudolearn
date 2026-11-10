import type { NormalizedRect } from "../catalog/catalog_types.ts";

export type Size = { readonly width: number; readonly height: number };

export type PixelRect = { readonly x: number; readonly y: number; readonly width: number; readonly height: number };

const EPSILON = 1e-6;

export function toPixels(rect: NormalizedRect, canvas: Size): PixelRect {
  return {
    x: rect.x * canvas.width,
    y: rect.y * canvas.height,
    width: rect.width * canvas.width,
    height: rect.height * canvas.height,
  };
}

export function contains(outer: PixelRect, inner: PixelRect): boolean {
  return inner.x >= outer.x - EPSILON
    && inner.y >= outer.y - EPSILON
    && inner.x + inner.width <= outer.x + outer.width + EPSILON
    && inner.y + inner.height <= outer.y + outer.height + EPSILON;
}

export function intersects(first: PixelRect, second: PixelRect): boolean {
  return first.x < second.x + second.width - EPSILON
    && second.x < first.x + first.width - EPSILON
    && first.y < second.y + second.height - EPSILON
    && second.y < first.y + first.height - EPSILON;
}

export function inset(rect: PixelRect, fraction: number): PixelRect {
  const dx = rect.width * fraction;
  const dy = rect.height * fraction;
  return { x: rect.x + dx, y: rect.y + dy, width: rect.width - 2 * dx, height: rect.height - 2 * dy };
}

export function centeredIn(container: PixelRect, size: Size): PixelRect {
  return {
    x: container.x + (container.width - size.width) / 2,
    y: container.y + (container.height - size.height) / 2,
    width: size.width,
    height: size.height,
  };
}
