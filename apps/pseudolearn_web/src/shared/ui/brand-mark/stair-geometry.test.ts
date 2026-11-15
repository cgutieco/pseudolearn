import { describe, expect, it } from 'vitest';
import { FLAG_VIEW_BOX, boundsViewBox, centerlinePoints, pathPoints, stairStart } from './stair-geometry';

describe('stair geometry', () => {
  it('reads every corner of the generated centerline', () => {
    const points = centerlinePoints();
    expect(points[0]).toEqual({ x: 10, y: 86 });
    expect(points.length).toBeGreaterThan(2);
  });

  it('reads decimal and negative coordinates', () => {
    expect(centerlinePoints('M -1.5,2 L 3,4.25')).toEqual([
      { x: -1.5, y: 2 },
      { x: 3, y: 4.25 },
    ]);
  });

  it('starts at the origin when the centerline is empty', () => {
    expect(centerlinePoints('')).toEqual([]);
    expect(stairStart('')).toEqual({ x: 0, y: 0 });
  });
});

describe('flag bounds', () => {
  it('reads move, line and arc end points but not arc radii', () => {
    expect(pathPoints('M 10,2 A 3,3 0 0 1 12,4 L 8,9 Z')).toEqual([
      { x: 10, y: 2 },
      { x: 12, y: 4 },
      { x: 8, y: 9 },
    ]);
  });

  it('wraps the points with padding', () => {
    expect(
      boundsViewBox([
        { x: 10, y: 2 },
        { x: 12, y: 9 },
      ]),
    ).toBe('9 1 4 9');
    expect(boundsViewBox([])).toBe('0 0 0 0');
  });

  it('frames the generated pennant inside the symbol', () => {
    const [left = 0, top = 0, width = 0, height = 0] = FLAG_VIEW_BOX.split(' ').map(Number);
    expect(left).toBeGreaterThan(50);
    expect(top).toBeGreaterThanOrEqual(0);
    expect(width).toBeGreaterThan(20);
    expect(height).toBeGreaterThan(20);
  });
});
