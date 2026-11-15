import type { Catalog, StoreId } from "../catalog/catalog_types.ts";
import { finding, type Finding } from "./finding.ts";

export const MINIMUM_CONTRAST = 4.5;

export function auditLexicon(catalog: Catalog, store: StoreId, texts: readonly string[]): readonly Finding[] {
  return texts.flatMap((text) => catalog.lexicon[store]
    .filter((entry) => entry.pattern.test(text))
    .map((entry) => finding("TEXT-LEXICON", text, `matches the ${entry.id} rule of ${store}`)));
}

export function contrastRatio(foreground: string, background: string): number {
  const lighter = Math.max(luminance(foreground), luminance(background));
  const darker = Math.min(luminance(foreground), luminance(background));
  return (lighter + 0.05) / (darker + 0.05);
}

export type ContrastPair = { readonly role: string; readonly foreground: string; readonly background: string };

export function auditContrast(pairs: readonly ContrastPair[]): readonly Finding[] {
  return pairs
    .filter((pair) => !(contrastRatio(pair.foreground, pair.background) >= MINIMUM_CONTRAST))
    .map((pair) => finding("TEXT-CONTRAST", pair.role,
      `${contrastRatio(pair.foreground, pair.background).toFixed(2)}:1 is below ${MINIMUM_CONTRAST}:1`));
}

function luminance(hex: string): number {
  const match = /^#([0-9a-f]{6})$/iu.exec(hex);
  if (!match?.[1]) {
    return Number.NaN;
  }
  const value = Number.parseInt(match[1], 16);
  const channels = [(value >> 16) & 0xff, (value >> 8) & 0xff, value & 0xff].map((channel) => {
    const normalized = channel / 255;
    return normalized <= 0.04045 ? normalized / 12.92 : ((normalized + 0.055) / 1.055) ** 2.4;
  });
  return 0.2126 * (channels[0] ?? 0) + 0.7152 * (channels[1] ?? 0) + 0.0722 * (channels[2] ?? 0);
}
