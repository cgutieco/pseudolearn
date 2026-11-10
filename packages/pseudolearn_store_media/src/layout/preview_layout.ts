import { fitHeadline, type HeadlineFit, type MeasureText } from "./headline_fit.ts";
import type { PixelRect, Size } from "./pixel_rect.ts";

export type CaptionRoleName = "headline" | "note" | "disclosure";

export type PixelInsets = { readonly top: number; readonly right: number; readonly bottom: number; readonly left: number };

export type CaptionBand = {
  readonly anchor: "top" | "bottom";
  readonly heightShare: number;
  readonly maximumShare: number;
  readonly minimumShare: number;
};

export type CaptionPlacement = {
  readonly panel: PixelRect;
  readonly text: PixelRect;
  readonly fit: HeadlineFit;
  readonly coverFraction: number;
};

export const CAPTION_LINE_HEIGHT = 1.08;
export const SIDE_MARGIN_SHARE = 0.05;
export const PANEL_PADDING_SHARE = 0.022;

export const CAPTION_BANDS: Readonly<Record<CaptionRoleName, CaptionBand>> = {
  headline: { anchor: "top", heightShare: 0.17, maximumShare: 0.078, minimumShare: 0.042 },
  note: { anchor: "bottom", heightShare: 0.1, maximumShare: 0.046, minimumShare: 0.03 },
  disclosure: { anchor: "bottom", heightShare: 0.07, maximumShare: 0.032, minimumShare: 0.024 },
};

export type CaptionRequest = {
  readonly canvas: Size;
  readonly insets: PixelInsets;
  readonly role: CaptionRoleName;
  readonly lines: readonly string[];
  readonly anchor: "top" | "bottom" | null;
};

export function placeCaption(request: CaptionRequest, measure: MeasureText): CaptionPlacement {
  const { canvas, insets } = request;
  const band = CAPTION_BANDS[request.role];
  const shortSide = Math.min(canvas.width, canvas.height);
  const margin = canvas.width * SIDE_MARGIN_SHARE;
  const padding = shortSide * PANEL_PADDING_SHARE;
  const boxWidth = canvas.width - insets.left - insets.right - 2 * margin - 2 * padding;
  const boxHeight = canvas.height * band.heightShare;
  const fit = fitHeadline({
    lines: request.lines, boxWidth, boxHeight, lineHeight: CAPTION_LINE_HEIGHT, measure,
    maximumFontSize: shortSide * band.maximumShare, minimumFontSize: shortSide * band.minimumShare,
  });
  const textWidth = fit.fits ? fit.width : boxWidth;
  const textHeight = fit.fits ? fit.height : boxHeight;
  const panelHeight = textHeight + 2 * padding;
  const anchor = request.anchor ?? band.anchor;
  const panelY = anchor === "top" ? insets.top + margin / 2 : canvas.height - insets.bottom - margin / 2 - panelHeight;
  const panel = { x: insets.left + margin, y: panelY, width: textWidth + 2 * padding, height: panelHeight };
  return {
    panel,
    text: { x: panel.x + padding, y: panel.y + padding, width: textWidth, height: textHeight },
    fit,
    coverFraction: (panel.width * panel.height) / (canvas.width * canvas.height),
  };
}

export function pixelInsets(insets: PixelInsets, scale: number): PixelInsets {
  return { top: insets.top * scale, right: insets.right * scale, bottom: insets.bottom * scale, left: insets.left * scale };
}
