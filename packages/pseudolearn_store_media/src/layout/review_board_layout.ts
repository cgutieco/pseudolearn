import type { Slot, ViewportProfile } from "../catalog/catalog_types.ts";
import { project, projectionOf } from "./crop_projection.ts";
import { toPixels, type PixelRect, type Size } from "./pixel_rect.ts";

export const REVIEW_CELL_WIDTH = 720;
export const REVIEW_CELL_MAX_HEIGHT = 420;
export const REVIEW_GUTTER = 32;
export const REVIEW_LABEL_HEIGHT = 48;
export const REVIEW_TITLE_HEIGHT = 120;

export type ReviewCell = {
  readonly label: string;
  readonly clip: PixelRect;
  readonly image: PixelRect;
  readonly safe: PixelRect;
  readonly occlusions: readonly PixelRect[];
};

export type ReviewRow = { readonly timeSeconds: number; readonly top: number; readonly cells: readonly ReviewCell[] };

export type ReviewBoard = { readonly size: Size; readonly rows: readonly ReviewRow[] };

type View = { readonly label: string; readonly viewport: Size; readonly occlusions: readonly PixelRect[] };

export function reviewBoardLayout(slot: Slot, times: readonly number[]): ReviewBoard {
  const canvas = { width: slot.width, height: slot.height };
  const views: readonly View[] = [{ label: "canvas", viewport: canvas, occlusions: [] }, ...slot.viewportProfiles.map(viewOf)];
  const scales = views.map((view) => Math.min(REVIEW_CELL_WIDTH / view.viewport.width, REVIEW_CELL_MAX_HEIGHT / view.viewport.height));
  const cellHeight = Math.max(...views.map((view, index) => view.viewport.height * (scales[index] ?? 1)));
  const rowHeight = REVIEW_LABEL_HEIGHT + cellHeight + REVIEW_GUTTER;
  const rows = times.map((timeSeconds, rowIndex) => {
    const top = REVIEW_TITLE_HEIGHT + rowIndex * rowHeight;
    const cells = views.map((view, column) => cellOf({ slot, view, scale: scales[column] ?? 1,
      origin: { x: REVIEW_GUTTER + column * (REVIEW_CELL_WIDTH + REVIEW_GUTTER), y: top + REVIEW_LABEL_HEIGHT } }));
    return { timeSeconds, top, cells };
  });
  const width = REVIEW_GUTTER + views.length * (REVIEW_CELL_WIDTH + REVIEW_GUTTER);
  return { size: { width, height: REVIEW_TITLE_HEIGHT + times.length * rowHeight }, rows };
}

function viewOf(profile: ViewportProfile): View {
  return { label: profile.name, viewport: profile.viewport, occlusions: profile.occlusions };
}

type CellRequest = { readonly slot: Slot; readonly view: View; readonly scale: number; readonly origin: { x: number; y: number } };

function cellOf(request: CellRequest): ReviewCell {
  const { slot, view, scale, origin } = request;
  const canvas = { width: slot.width, height: slot.height };
  const projection = projectionOf({ name: view.label, viewport: view.viewport, occlusions: [] }, canvas);
  const place = (rect: PixelRect): PixelRect => ({
    x: origin.x + rect.x * scale, y: origin.y + rect.y * scale, width: rect.width * scale, height: rect.height * scale,
  });
  return {
    label: view.label,
    clip: place({ x: 0, y: 0, ...view.viewport }),
    image: place(project({ x: 0, y: 0, ...canvas }, projection)),
    safe: place(project(toPixels(slot.safeArea, canvas), projection)),
    occlusions: view.occlusions.map(place),
  };
}
