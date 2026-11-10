import type { Device, DeviceFrame } from "../catalog/catalog_types.ts";
import type { PixelRect } from "./pixel_rect.ts";

export type DevicePlacement = {
  readonly outer: PixelRect;
  readonly screen: PixelRect;
  readonly screenRadius: number;
  readonly rotation: number;
};

type Insets = { readonly side: number; readonly top: number; readonly bottom: number; readonly overhang: number };

const INSETS: Readonly<Record<DeviceFrame, Insets>> = {
  phone: { side: 0.034, top: 0.034, bottom: 0.034, overhang: 0 },
  tablet: { side: 0.03, top: 0.03, bottom: 0.03, overhang: 0 },
  foldable: { side: 0.02, top: 0.02, bottom: 0.02, overhang: 0 },
  window: { side: 0.022, top: 0.031, bottom: 0.066, overhang: 0.06 },
};

export function deviceAspect(device: Device): number {
  const insets = INSETS[device.frame];
  const width = 1 + 2 * insets.side + 2 * insets.overhang;
  const height = device.logicalHeight / device.logicalWidth + insets.top + insets.bottom;
  return width / height;
}

export function placeDevice(device: Device, anchor: { x: number; y: number; width: number; rotation: number }): DevicePlacement {
  const insets = INSETS[device.frame];
  const screenWidth = anchor.width / (1 + 2 * insets.side + 2 * insets.overhang);
  const screenHeight = (screenWidth * device.logicalHeight) / device.logicalWidth;
  return {
    outer: { x: anchor.x, y: anchor.y, width: anchor.width, height: screenHeight + (insets.top + insets.bottom) * screenWidth },
    screen: {
      x: anchor.x + (insets.overhang + insets.side) * screenWidth,
      y: anchor.y + insets.top * screenWidth,
      width: screenWidth,
      height: screenHeight,
    },
    screenRadius: (device.cornerRadius * screenWidth) / device.logicalWidth,
    rotation: anchor.rotation,
  };
}

export function fitDevice(device: Device, region: PixelRect): DevicePlacement {
  const aspect = deviceAspect(device);
  const width = Math.min(region.width, region.height * aspect);
  const height = width / aspect;
  return placeDevice(device, { x: region.x + (region.width - width) / 2, y: region.y + (region.height - height) / 2, width, rotation: 0 });
}
