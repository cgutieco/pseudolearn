import type { PixelRect, Size } from "./pixel_rect.ts";

export const REFERENCE_WIDTH = 1920;

export type ThermostatLayout = {
  readonly unit: number;
  readonly code: { readonly x: number; readonly y: number; readonly lineHeight: number; readonly fontSize: number };
  readonly numbers: { readonly x: number; readonly bigSize: number; readonly smallSize: number; readonly labelSize: number };
  readonly closingSize: number;
  readonly program: PixelRect;
  readonly overflow: readonly string[];
};

export type ThermostatLayoutRequest = {
  readonly canvas: Size;
  readonly lines: readonly string[];
  readonly closing: string;
  readonly measure: { readonly mono: (text: string, size: number) => number; readonly sans: (text: string, size: number) => number };
};

const GUTTER = 40;

export function thermostatLayout(request: ThermostatLayoutRequest): ThermostatLayout {
  const unit = request.canvas.width / REFERENCE_WIDTH;
  const code = { x: 140 * unit, y: 250 * unit, lineHeight: 46 * unit, fontSize: 25 * unit };
  const numbers = { x: 1318 * unit, bigSize: 380 * unit, smallSize: 140 * unit, labelSize: 30 * unit };
  const closingSize = 84 * unit;
  const overflow = [
    ...request.lines.filter((line) => code.x + request.measure.mono(line, code.fontSize) > numbers.x - GUTTER * unit),
    ...(request.measure.sans(request.closing, closingSize) > request.canvas.width - 2 * code.x ? [request.closing] : []),
  ];
  const program = { x: 120 * unit, y: 200 * unit, width: 1700 * unit, height: 760 * unit };
  return { unit, code, numbers, closingSize, program, overflow };
}
