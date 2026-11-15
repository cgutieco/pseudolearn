import type { FoldAxis } from "../catalog/catalog_types.ts";
import type { DevicePlacement } from "./device_geometry.ts";
import type { PixelRect, Size } from "./pixel_rect.ts";

export const FOLD_ANGLE_DEGREES = 10;

export type PinRequest = {
  readonly placement: DevicePlacement;
  readonly plate: Size;
  readonly focus: PixelRect;
  readonly pin: { readonly x: number; readonly y: number };
};

export type PillRequest = {
  readonly pin: { readonly x: number; readonly y: number };
  readonly size: Size;
  readonly safe: PixelRect;
  readonly avoid: PixelRect;
};

export type FoldContext = { readonly axis: FoldAxis; readonly placement: DevicePlacement };

export function plateToCanvas(request: PinRequest, fold: FoldAxis): { readonly point: { x: number; y: number }; readonly highlight: PixelRect } {
  const { placement, plate } = request;
  const focus = clampToPlate(request.focus, plate);
  const scale = placement.screen.width / plate.width;
  const project = (x: number, y: number) => folded({ x: placement.screen.x + x * scale, y: placement.screen.y + y * scale }, { axis: fold, placement });
  const topLeft = project(focus.x, focus.y);
  const bottomRight = project(focus.x + focus.width, focus.y + focus.height);
  return {
    point: project(focus.x + focus.width * request.pin.x, focus.y + focus.height * request.pin.y),
    highlight: { x: topLeft.x, y: topLeft.y, width: bottomRight.x - topLeft.x, height: bottomRight.y - topLeft.y },
  };
}

export function placePill(request: PillRequest): PixelRect {
  const { pin, size, safe, avoid } = request;
  const gap = size.height * 0.45;
  const x = Math.min(Math.max(pin.x - size.height, safe.x), safe.x + safe.width - size.width);
  const above = pin.y - gap - size.height;
  const sideBySide = x >= avoid.x + avoid.width || x + size.width <= avoid.x;
  const y = above >= safe.y && (sideBySide || above >= avoid.y + avoid.height) ? above : pin.y + gap;
  return { x, y: Math.min(y, safe.y + safe.height - size.height), width: size.width, height: size.height };
}

function folded(point: { x: number; y: number }, context: FoldContext): { x: number; y: number } {
  const { screen } = context.placement;
  const shrink = Math.cos((FOLD_ANGLE_DEGREES * Math.PI) / 180);
  if (context.axis === "vertical") {
    const hinge = screen.x + screen.width / 2;
    return { x: hinge + (point.x - hinge) * shrink, y: point.y };
  }
  if (context.axis === "horizontal") {
    const hinge = screen.y + screen.height / 2;
    return { x: point.x, y: hinge + (point.y - hinge) * shrink };
  }
  return point;
}

function clampToPlate(rect: PixelRect, plate: Size): PixelRect {
  const x = Math.min(Math.max(rect.x, 0), plate.width);
  const y = Math.min(Math.max(rect.y, 0), plate.height);
  return { x, y, width: Math.min(rect.x + rect.width, plate.width) - x, height: Math.min(rect.y + rect.height, plate.height) - y };
}
