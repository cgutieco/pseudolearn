import type { LensLayout } from "../layout/lens_layout.ts";
import { finding, type Finding } from "./finding.ts";

export const LABEL_BREATHING = 0.2;

export function auditLensLabels(target: string, layout: LensLayout, sansWidth: (text: string, size: number) => number): readonly Finding[] {
  const seen = new Set<string>();
  return layout.rows.flatMap((row) => row.segments).flatMap((segment) => {
    if (segment.form === "dot" || seen.has(segment.text)) {
      return [];
    }
    seen.add(segment.text);
    const room = segment.nodeWidth - segment.nodeHeight * LABEL_BREATHING;
    const width = sansWidth(segment.text, layout.sansSize);
    return width <= room ? [] : [finding("TEXT-FIT", target, `"${segment.text}" needs ${width.toFixed(0)} px in a ${room.toFixed(0)} px node`)];
  });
}

export function auditLensRows(target: string, layout: LensLayout): readonly Finding[] {
  const inside = layout.rows.filter((row) => row.inLens).length;
  return inside > 0 ? [] : [finding("MEDIA-SAFE-AREA", target, "no row of the diagram passes through the lens")];
}
