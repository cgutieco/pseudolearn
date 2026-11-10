import type { Slot } from "../catalog/catalog_types.ts";
import { projectionOf, unproject } from "./crop_projection.ts";
import { intersects, toPixels, type PixelRect } from "./pixel_rect.ts";

export function clearZone(slot: Slot): PixelRect {
  const canvas = { width: slot.width, height: slot.height };
  let zone = toPixels(slot.safeArea, canvas);
  for (const profile of slot.viewportProfiles) {
    const projection = projectionOf(profile, canvas);
    zone = intersection(zone, unproject({ x: 0, y: 0, ...profile.viewport }, projection));
    for (const occlusion of profile.occlusions) {
      zone = trimmedAround(zone, unproject(occlusion, projection));
    }
  }
  return zone;
}

export function intersection(first: PixelRect, second: PixelRect): PixelRect {
  const left = Math.max(first.x, second.x);
  const top = Math.max(first.y, second.y);
  const right = Math.min(first.x + first.width, second.x + second.width);
  const bottom = Math.min(first.y + first.height, second.y + second.height);
  return { x: left, y: top, width: Math.max(0, right - left), height: Math.max(0, bottom - top) };
}

function trimmedAround(zone: PixelRect, obstacle: PixelRect): PixelRect {
  if (!intersects(zone, obstacle)) {
    return zone;
  }
  const right = zone.x + zone.width;
  const bottom = zone.y + zone.height;
  const candidates: PixelRect[] = [
    { ...zone, y: obstacle.y + obstacle.height, height: bottom - (obstacle.y + obstacle.height) },
    { ...zone, height: obstacle.y - zone.y },
    { ...zone, x: obstacle.x + obstacle.width, width: right - (obstacle.x + obstacle.width) },
    { ...zone, width: obstacle.x - zone.x },
  ].filter((candidate) => candidate.width > 0 && candidate.height > 0);
  const best = candidates.reduce<PixelRect | null>((kept, candidate) =>
    kept === null || candidate.width * candidate.height > kept.width * kept.height ? candidate : kept, null);
  return best ?? { ...zone, width: 0, height: 0 };
}
