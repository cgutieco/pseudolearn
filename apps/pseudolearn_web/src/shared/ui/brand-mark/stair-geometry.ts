import {
  BRAND_SYMBOL_CENTERLINE,
  BRAND_SYMBOL_FLAG_PATH,
  BRAND_SYMBOL_STROKE,
} from './symbol-path.generated';

export interface StairPoint {
  readonly x: number;
  readonly y: number;
}

const COORDINATES = /(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)/g;

export function centerlinePoints(centerline: string = BRAND_SYMBOL_CENTERLINE): readonly StairPoint[] {
  return [...centerline.matchAll(COORDINATES)].map(([, x = '0', y = '0']) => ({
    x: Number(x),
    y: Number(y),
  }));
}

export function stairStart(centerline: string = BRAND_SYMBOL_CENTERLINE): StairPoint {
  return centerlinePoints(centerline)[0] ?? { x: 0, y: 0 };
}

export const STAIR_WALK_WIDTH = BRAND_SYMBOL_STROKE + 2;
export const STAIR_NODE_RADIUS = BRAND_SYMBOL_STROKE;

const PATH_POINTS =
  /[ML]\s*(-?[\d.]+),(-?[\d.]+)|A\s*[\d.]+,[\d.]+\s+\S+\s+\S+\s+\S+\s+(-?[\d.]+),(-?[\d.]+)/g;

export function pathPoints(path: string): readonly StairPoint[] {
  return [...path.matchAll(PATH_POINTS)].map((match) => ({
    x: Number(match[1] ?? match[3]),
    y: Number(match[2] ?? match[4]),
  }));
}

export function boundsViewBox(points: readonly StairPoint[], padding = 1): string {
  if (points.length === 0) return '0 0 0 0';
  const xs = points.map((point) => point.x);
  const ys = points.map((point) => point.y);
  const left = Math.min(...xs) - padding;
  const top = Math.min(...ys) - padding;
  const width = Math.max(...xs) - left + padding;
  const height = Math.max(...ys) - top + padding;
  return [left, top, width, height].map((value) => Number(value.toFixed(3))).join(' ');
}

export const FLAG_VIEW_BOX = boundsViewBox(pathPoints(BRAND_SYMBOL_FLAG_PATH));
