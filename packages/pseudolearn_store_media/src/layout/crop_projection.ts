import { contains, intersects, type PixelRect, type Size } from "./pixel_rect.ts";

export type ViewportProfile = {
  readonly name: string;
  readonly viewport: Size;
  readonly occlusions: readonly PixelRect[];
};

export type Projection = { readonly scale: number; readonly offsetX: number; readonly offsetY: number };

export function projectionOf(profile: ViewportProfile, canvas: Size): Projection {
  const scale = Math.max(profile.viewport.width / canvas.width, profile.viewport.height / canvas.height);
  return {
    scale,
    offsetX: (profile.viewport.width - canvas.width * scale) / 2,
    offsetY: (profile.viewport.height - canvas.height * scale) / 2,
  };
}

export function project(rect: PixelRect, projection: Projection): PixelRect {
  return {
    x: projection.offsetX + rect.x * projection.scale,
    y: projection.offsetY + rect.y * projection.scale,
    width: rect.width * projection.scale,
    height: rect.height * projection.scale,
  };
}

export function isClearIn(profile: ViewportProfile, canvas: Size, rect: PixelRect): boolean {
  const projected = project(rect, projectionOf(profile, canvas));
  const visible = { x: 0, y: 0, width: profile.viewport.width, height: profile.viewport.height };
  return contains(visible, projected) && !profile.occlusions.some((occlusion) => intersects(occlusion, projected));
}
