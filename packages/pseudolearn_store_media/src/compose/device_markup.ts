import type { Device } from "../catalog/catalog_types.ts";
import type { DevicePlacement } from "../layout/device_geometry.ts";
import { FOLD_ANGLE_DEGREES } from "../layout/pin_layout.ts";
import { rectStyle } from "./html_text.ts";

export type DeviceMarkupRequest = {
  readonly device: Device;
  readonly placement: DevicePlacement;
  readonly plateFile: string;
};

const BODY = "linear-gradient(145deg,#5b6467,#1a1f21 30%,#0b0e0f 60%,#3e4649)";
const SHADOW = "0 60px 150px rgba(0,0,0,.35)";

export function deviceMarkup(request: DeviceMarkupRequest): string {
  const { device, placement } = request;
  const inner = device.frame === "window" ? laptop(request) : device.frame === "foldable" ? foldable(request) : slab(request);
  const center = `${placement.outer.width / 2}px ${placement.outer.height / 2}px`;
  return `<div class="device" style="${rectStyle(placement.outer)}transform-origin:${center};transform:rotate(${placement.rotation}deg)">${inner}</div>`;
}

function local(placement: DevicePlacement) {
  return { x: placement.screen.x - placement.outer.x, y: placement.screen.y - placement.outer.y, width: placement.screen.width, height: placement.screen.height };
}

function slab(request: DeviceMarkupRequest): string {
  const { placement, plateFile } = request;
  const screen = local(placement);
  const bezel = screen.x;
  return `<div style="position:absolute;inset:0;border-radius:${placement.screenRadius + bezel}px;background:${BODY};box-shadow:${SHADOW}"></div>
<div style="position:absolute;inset:${bezel * 0.35}px;border-radius:${placement.screenRadius + bezel * 0.65}px;background:#050708"></div>
<div style="${rectStyle(screen)}border-radius:${placement.screenRadius}px;overflow:hidden;background:url('${plateFile}') 0 0/100% 100% no-repeat"></div>`;
}

function laptop(request: DeviceMarkupRequest): string {
  const { placement, plateFile } = request;
  const screen = local(placement);
  const lid = { x: screen.x - screen.width * 0.022, y: 0, width: screen.width * 1.044, height: screen.y + screen.height + screen.width * 0.031 };
  const base = { x: 0, y: lid.height, width: placement.outer.width, height: placement.outer.height - lid.height };
  const radius = screen.width * 0.022;
  return `<div style="${rectStyle(lid)}border-radius:${radius}px ${radius}px 0 0;background:linear-gradient(160deg,#4a5255,#0d1112 40%,#1b2022);box-shadow:${SHADOW}"></div>
<div style="${rectStyle(screen)}background:url('${plateFile}') 0 0/100% 100% no-repeat;border-radius:${placement.screenRadius}px"></div>
<div style="${rectStyle(base)}border-radius:0 0 ${radius * 1.8}px ${radius * 1.8}px;background:linear-gradient(180deg,#d4d9db,#8d9497 45%,#5d6467);box-shadow:0 40px 80px rgba(0,0,0,.3)"></div>`;
}

function foldable(request: DeviceMarkupRequest): string {
  const { placement, plateFile, device } = request;
  const vertical = device.fold === "vertical";
  const outer = { width: placement.outer.width, height: placement.outer.height };
  const screen = local(placement);
  const halves = [0, 1].map((index) => {
    const half = vertical
      ? { x: index * outer.width / 2, y: 0, width: outer.width / 2, height: outer.height }
      : { x: 0, y: index * outer.height / 2, width: outer.width, height: outer.height / 2 };
    const origin = vertical ? (index === 0 ? "right center" : "left center") : (index === 0 ? "center bottom" : "center top");
    const angle = (index === 0 ? 1 : -1) * FOLD_ANGLE_DEGREES;
    const rotate = vertical ? `rotateY(${angle}deg)` : `rotateX(${-angle}deg)`;
    const view = { x: screen.x - half.x, y: screen.y - half.y, width: screen.width, height: screen.height };
    return `<div style="${rectStyle(half)}overflow:hidden;transform-origin:${origin};transform:${rotate}">
<div style="position:absolute;left:${-half.x}px;top:${-half.y}px;width:${outer.width}px;height:${outer.height}px;border-radius:${placement.screenRadius + screen.x}px;background:${BODY}"></div>
<div style="${rectStyle(view)}border-radius:${placement.screenRadius}px;background:url('${plateFile}') 0 0/100% 100% no-repeat"></div>
<div style="position:absolute;inset:0;background:linear-gradient(${vertical ? (index === 0 ? "90deg" : "270deg") : (index === 0 ? "180deg" : "0deg")}, rgba(0,0,0,0) 72%, rgba(0,0,0,.22))"></div></div>`;
  });
  return `<div style="position:absolute;inset:0;perspective:${Math.max(outer.width, outer.height) * 2.4}px;filter:drop-shadow(0 50px 70px rgba(0,0,0,.3))">${halves.join("")}</div>`;
}
