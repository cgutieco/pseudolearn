import type { Slot } from "../catalog/catalog_types.ts";
import type { MuteLensLayout } from "../layout/mute_lens_layout.ts";
import type { StatementKind } from "../story/lens_story.ts";
import { htmlDocument, type Composition } from "./composition.ts";
import { LENS_PALETTE as P } from "./lens_palette.ts";
import { lensNodes, riverBars } from "./mute_lens_markup.ts";

export type MuteLensRequest = {
  readonly id: string;
  readonly slot: Slot;
  readonly layout: MuteLensLayout;
  readonly kinds: readonly StatementKind[];
};

export function buildMuteLens(request: MuteLensRequest): Composition {
  const { slot, layout, id } = request;
  const canvas = { width: slot.width, height: slot.height };
  const { lens } = layout;
  const radius = Math.min(lens.width, lens.height) * 0.15;
  const unit = layout.rowGap;
  const shape = `x="${lens.x}" y="${lens.y}" width="${lens.width}" height="${lens.height}" rx="${radius}"`;
  const svg = `<svg width="${canvas.width}" height="${canvas.height}" viewBox="0 0 ${canvas.width} ${canvas.height}">
<defs><filter id="halo"><feGaussianBlur stdDeviation="${(unit * 0.11).toFixed(1)}"/></filter>
<filter id="shadow" x="-20%" y="-20%" width="140%" height="160%"><feDropShadow dx="0" dy="${(unit * 0.42).toFixed(0)}" stdDeviation="${(unit * 0.54).toFixed(0)}" flood-color="#072D2F" flood-opacity=".42"/></filter>
<radialGradient id="lensfill" cx="50%" cy="40%" r="70%"><stop offset="0" stop-color="${P.lensCenter}"/><stop offset=".7" stop-color="${P.lensEdge}"/></radialGradient>
<clipPath id="lensclip"><rect ${shape}/></clipPath>
<linearGradient id="fade" x1="0" y1="0" x2="0" y2="1"><stop offset=".55" stop-color="${P.field}" stop-opacity="0"/><stop offset="1" stop-color="#EFEBE0" stop-opacity=".9"/></linearGradient></defs>
<rect width="${canvas.width}" height="${canvas.height}" fill="${P.field}"/>${riverBars(layout)}<rect width="${canvas.width}" height="${canvas.height}" fill="url(#fade)"/>
<rect ${shape} fill="url(#lensfill)" filter="url(#shadow)"/><g clip-path="url(#lensclip)">${lensNodes(layout, request.kinds)}</g>
<rect ${shape} fill="none" stroke="${P.rim}" stroke-width="${(unit * 0.036).toFixed(1)}"/></svg>`;
  const html = htmlDocument({ id, canvas, durationSeconds: 1, style: `#stage { background: ${P.field}; }`, body: svg, timeline: "" });
  const elements = [
    { name: "river", rect: { x: 0, y: 0, ...canvas }, essential: false, content: "artwork" as const },
    { name: "lens", rect: lens, essential: true, content: "artwork" as const },
  ];
  return { id, canvas, durationSeconds: 1, html, layout: [{ timeSeconds: 0, elements }], texts: [] };
}
