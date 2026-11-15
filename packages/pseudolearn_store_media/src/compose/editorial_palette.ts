import type { PaletteId } from "../story/screenshot_story.ts";
import { BRAND_DEEP, BRAND_GROUND_BOTTOM, BRAND_GROUND_TOP } from "./brand.generated.ts";

export type EditorialPalette = {
  readonly field: string;
  readonly ink: string;
  readonly marker: string;
  readonly label: string;
  readonly texture: string;
  readonly textureOpacity: number;
  readonly pill: string;
  readonly pillInk: string;
  readonly frame: string;
  readonly veil: string;
};

const LIGHT_PILL = { pill: BRAND_GROUND_BOTTOM, pillInk: "#FFFFFF", frame: BRAND_GROUND_TOP, label: "#1D6467", textureOpacity: 0.05 };

export const EDITORIAL_PALETTES: Readonly<Record<PaletteId, EditorialPalette>> = {
  paper: { ...LIGHT_PILL, field: "#F7F4EC", ink: BRAND_DEEP, marker: "#B9E4E6", texture: BRAND_GROUND_TOP, veil: "rgba(247,244,236,.32)" },
  mint: { ...LIGHT_PILL, field: "#EBF9FA", ink: "#072D2F", marker: "#B9E4E6", texture: "#072D2F", veil: "rgba(235,249,250,.32)" },
  sand: { ...LIGHT_PILL, field: "#FFF5E2", ink: "#342400", marker: "#F4D69F", texture: "#342400", veil: "rgba(255,245,226,.32)" },
  peach: { ...LIGHT_PILL, field: "#FFF3EC", ink: "#3F1C00", marker: "#FFCFAF", texture: "#3F1C00", veil: "rgba(255,243,236,.32)" },
  mist: { ...LIGHT_PILL, field: "#F1F5F6", ink: "#151D20", marker: "#D3DBDD", texture: "#151D20", veil: "rgba(241,245,246,.32)" },
  deep: {
    field: "#072D2F", ink: "#FFFFFF", marker: "#9C4F01", label: "#95D1D4", texture: "#4AA4A8", textureOpacity: 0.09,
    pill: "#F29045", pillInk: "#1B0E00", frame: "#F29045", veil: "rgba(4,10,11,.38)",
  },
};

export const CODE_CARD = { background: BRAND_DEEP, ink: "#E6ECED", keyword: "#F29045", literal: "#95D1D4" };

export function editorialContrastPairs(palette: EditorialPalette) {
  return [
    { role: "headline", foreground: palette.ink, background: palette.field },
    { role: "marked headline", foreground: palette.ink, background: palette.marker },
    { role: "chapter label", foreground: palette.label, background: palette.field },
    { role: "note", foreground: palette.pillInk, background: palette.pill },
    { role: "code", foreground: CODE_CARD.ink, background: CODE_CARD.background },
    { role: "code keyword", foreground: CODE_CARD.keyword, background: CODE_CARD.background },
  ];
}
