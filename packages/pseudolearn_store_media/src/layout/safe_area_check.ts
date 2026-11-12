import type { Slot } from "../catalog/catalog_types.ts";
import { isClearIn, type ViewportProfile } from "./crop_projection.ts";
import { contains, toPixels, type PixelRect } from "./pixel_rect.ts";

export const CONTENT_KINDS = ["app-interface", "added-text", "added-mark", "artwork"] as const;
export type ContentKind = (typeof CONTENT_KINDS)[number];

export type PlacedElement = {
  readonly name: string;
  readonly rect: PixelRect;
  readonly essential: boolean;
  readonly content?: ContentKind;
};

export type FrameLayout = { readonly timeSeconds: number; readonly elements: readonly PlacedElement[] };

export type SafeAreaViolation = {
  readonly timeSeconds: number;
  readonly element: string;
  readonly reason: string;
};

export type SafeAreaRequest = {
  readonly slot: Slot;
  readonly frames: readonly FrameLayout[];
  readonly profiles: readonly ViewportProfile[];
};

export function checkSafeArea(request: SafeAreaRequest): readonly SafeAreaViolation[] {
  const canvas = { width: request.slot.width, height: request.slot.height };
  const canvasRect = { x: 0, y: 0, ...canvas };
  const safeRect = toPixels(request.slot.safeArea, canvas);
  return request.frames.flatMap((frame) => frame.elements.flatMap((element) => {
    const reasons = reasonsFor({ element, canvasRect, safeRect, profiles: request.profiles });
    return reasons.map((reason) => ({ timeSeconds: frame.timeSeconds, element: element.name, reason }));
  }));
}

type ElementContext = {
  readonly element: PlacedElement;
  readonly canvasRect: PixelRect;
  readonly safeRect: PixelRect;
  readonly profiles: readonly ViewportProfile[];
};

function reasonsFor(context: ElementContext): readonly string[] {
  const { element, canvasRect, safeRect, profiles } = context;
  if (!contains(canvasRect, element.rect)) {
    return ["leaves the canvas"];
  }
  if (!element.essential) {
    return [];
  }
  const reasons = contains(safeRect, element.rect) ? [] : ["leaves the safe area"];
  const canvas = { width: canvasRect.width, height: canvasRect.height };
  for (const profile of profiles) {
    if (!isClearIn(profile, canvas, element.rect)) {
      reasons.push(`is cropped or covered in ${profile.name}`);
    }
  }
  return reasons;
}
