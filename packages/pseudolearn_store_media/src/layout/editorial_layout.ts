import type { Device } from "../catalog/catalog_types.ts";
import { fitDevice, placeDevice, type DevicePlacement } from "./device_geometry.ts";
import type { PixelRect, Size } from "./pixel_rect.ts";

const LANDSCAPE_DEVICE_SHARE = 0.6;

export type EditorialKind = "manifesto" | "device";

export type EditorialLayoutRequest = {
  readonly canvas: Size;
  readonly safe: PixelRect;
  readonly device: Device;
  readonly kind: EditorialKind;
};

export type TextSizes = { readonly maximum: number; readonly minimum: number };

export type EditorialLayout = {
  readonly orientation: "portrait" | "landscape";
  readonly label: { readonly x: number; readonly y: number; readonly size: number };
  readonly headline: PixelRect;
  readonly headlineSizes: TextSizes;
  readonly subline: PixelRect | null;
  readonly sublineSizes: TextSizes;
  readonly code: PixelRect | null;
  readonly codeSizes: TextSizes;
  readonly noteSize: number;
  readonly device: DevicePlacement | null;
};

export function editorialLayout(request: EditorialLayoutRequest): EditorialLayout {
  return request.canvas.height >= request.canvas.width ? portrait(request) : landscape(request);
}

function portrait(request: EditorialLayoutRequest): EditorialLayout {
  const { canvas, safe, device, kind } = request;
  const unit = canvas.width;
  const headline = { x: safe.x, y: safe.y + 0.05 * canvas.height, width: safe.width, height: (kind === "manifesto" ? 0.17 : 0.2) * canvas.height };
  const subline = kind === "manifesto" ? below(headline, 0.015 * canvas.height, 0.07 * canvas.height) : null;
  const code = subline ? below(subline, 0.025 * canvas.height, 0.14 * canvas.height) : null;
  const deviceTop = (code ?? headline).y + (code ?? headline).height + (code ? 0.04 : 0.045) * canvas.height;
  const deviceWidth = (kind === "manifesto" ? 0.74 : 0.82) * unit;
  return {
    orientation: "portrait",
    label: { x: safe.x, y: safe.y + 0.012 * canvas.height, size: 0.03 * unit },
    headline,
    headlineSizes: { maximum: 0.112 * unit, minimum: 0.05 * unit },
    subline,
    sublineSizes: { maximum: 0.038 * unit, minimum: 0.022 * unit },
    code,
    codeSizes: { maximum: 0.042 * unit, minimum: 0.022 * unit },
    noteSize: 0.035 * unit,
    device: placeDevice(device, { x: (canvas.width - deviceWidth) / 2, y: deviceTop, width: deviceWidth, rotation: kind === "manifesto" ? -4 : 0 }),
  };
}

function landscape(request: EditorialLayoutRequest): EditorialLayout {
  const { canvas, safe, device, kind } = request;
  const unit = canvas.height;
  const column = { x: safe.x, width: 0.42 * safe.width };
  const headline = { ...column, y: safe.y + 0.22 * safe.height, height: 0.46 * safe.height };
  const subline = kind === "manifesto" ? below(headline, 0.02 * safe.height, 0.18 * safe.height) : null;
  const right = { x: safe.x + 0.47 * safe.width, y: safe.y, width: 0.53 * safe.width, height: safe.height };
  return {
    orientation: "landscape",
    label: { x: safe.x, y: headline.y - 0.07 * unit, size: 0.024 * unit },
    headline,
    headlineSizes: { maximum: 0.095 * unit, minimum: 0.045 * unit },
    subline,
    sublineSizes: { maximum: 0.036 * unit, minimum: 0.02 * unit },
    code: kind === "manifesto" ? { x: right.x, y: right.y + 0.3 * right.height, width: right.width, height: 0.4 * right.height } : null,
    codeSizes: { maximum: 0.042 * unit, minimum: 0.02 * unit },
    noteSize: 0.026 * unit,
    device: kind === "manifesto" ? null : bleedRight(request, safe.x + 0.45 * safe.width),
  };
}

function bleedRight(request: EditorialLayoutRequest, left: number): DevicePlacement {
  const { canvas, safe, device } = request;
  const fitted = fitDevice(device, { x: left, y: safe.y, width: LANDSCAPE_DEVICE_SHARE * canvas.width, height: safe.height });
  return placeDevice(device, { x: left, y: fitted.outer.y, width: fitted.outer.width, rotation: 0 });
}

function below(rect: PixelRect, gap: number, height: number): PixelRect {
  return { x: rect.x, y: rect.y + rect.height + gap, width: rect.width, height };
}
