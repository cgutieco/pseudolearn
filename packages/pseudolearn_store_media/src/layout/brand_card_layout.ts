import { fitHeadline, type HeadlineFit, type MeasureText } from "./headline_fit.ts";
import type { PixelRect, Size } from "./pixel_rect.ts";
import type { PixelInsets } from "./preview_layout.ts";

export type BrandCardRequest = {
  readonly canvas: Size;
  readonly insets: PixelInsets;
  readonly kind: "opening" | "closing";
  readonly lockupAspect: number;
  readonly lines: readonly string[];
};

export type BrandCardPlacement = {
  readonly card: PixelRect;
  readonly lockup: PixelRect;
  readonly text: PixelRect | null;
  readonly fit: HeadlineFit | null;
  readonly coverFraction: number;
};

export const CARD_WIDTH_SHARE = 0.8;
export const CARD_HEIGHT_LIMIT_SHARE = 0.9;
export const LOCKUP_WIDTH_SHARE = 0.72;
export const CARD_PADDING_SHARE = 0.07;
export const CARD_TEXT_SHARES = { maximum: 0.034, minimum: 0.026 };
export const OPENING_CENTER_SHARE = 0.5;
export const CARD_LINE_HEIGHT = 1.2;

export function placeBrandCard(request: BrandCardRequest, measure: MeasureText): BrandCardPlacement {
  const { canvas, insets } = request;
  const short = Math.min(canvas.width, canvas.height);
  const width = Math.min(canvas.width * CARD_WIDTH_SHARE, canvas.height * CARD_HEIGHT_LIMIT_SHARE);
  const padding = short * CARD_PADDING_SHARE;
  const lockupWidth = width * LOCKUP_WIDTH_SHARE;
  const lockupHeight = lockupWidth / request.lockupAspect;
  const fit = request.lines.length === 0 ? null : fitHeadline({
    lines: request.lines, boxWidth: width - padding, boxHeight: short * 0.2, lineHeight: CARD_LINE_HEIGHT, measure,
    maximumFontSize: short * CARD_TEXT_SHARES.maximum, minimumFontSize: short * CARD_TEXT_SHARES.minimum,
  });
  const textHeight = fit ? request.lines.length * fit.fontSize * CARD_LINE_HEIGHT : 0;
  const height = 2 * padding + lockupHeight + (fit ? padding / 2 + textHeight : 0);
  const x = (canvas.width - width) / 2;
  const y = request.kind === "opening"
    ? canvas.height * OPENING_CENTER_SHARE - height / 2
    : canvas.height - insets.bottom - short * 0.06 - height;
  const card = { x, y, width, height };
  return {
    card,
    lockup: { x: x + (width - lockupWidth) / 2, y: y + padding, width: lockupWidth, height: lockupHeight },
    text: fit ? { x, y: y + padding + lockupHeight + padding / 2, width, height: textHeight } : null,
    fit,
    coverFraction: (width * height) / (canvas.width * canvas.height),
  };
}
