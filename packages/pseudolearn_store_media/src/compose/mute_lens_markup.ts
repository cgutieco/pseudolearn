import type { CodeBarRole, CodeSegment } from "../layout/code_bars.ts";
import type { MuteLensLayout, MuteLensRow } from "../layout/mute_lens_layout.ts";
import { NODE_MARGIN_ROWS } from "../layout/mute_lens_layout.ts";
import type { StatementKind } from "../story/lens_story.ts";
import { LENS_PALETTE as P } from "./lens_palette.ts";

export const ROLE_COLORS: Readonly<Record<CodeBarRole, string>> = {
  keyword: "#195C5F", number: "#E07A2E", text: "#2E8B57", symbol: "#6B8A8C", name: "#0F4346",
};
export const BAR_OPACITY = 0.22;
const GLOW_WIDTH_ROWS = 1.3;

export function riverBars(layout: MuteLensLayout): string {
  return layout.rows.flatMap((row) => row.segments.flatMap((segment) => segment.bars)).map((bar) =>
    `<rect x="${bar.x.toFixed(1)}" y="${bar.y.toFixed(1)}" width="${bar.width.toFixed(1)}" height="${bar.height.toFixed(1)}" rx="${(bar.height / 2).toFixed(1)}" fill="${ROLE_COLORS[bar.role]}" opacity="${BAR_OPACITY}"/>`).join("");
}

export function lensNodes(layout: MuteLensLayout, kinds: readonly StatementKind[]): string {
  const centre = layout.lens.x + layout.lens.width / 2;
  const margin = layout.rowGap * NODE_MARGIN_ROWS;
  return layout.rows.filter((row) => row.inLens).map((row) => {
    const visible = row.segments.filter((segment) => segment.center > layout.lens.x - margin && segment.center < layout.lens.x + layout.lens.width + margin);
    return visible.map((segment, index) => {
      const next = visible[index + 1];
      const glow = row.middle ? Math.exp(-(((segment.center - centre) / (layout.rowGap * GLOW_WIDTH_ROWS)) ** 2)) : 0;
      const place = { row, unit: layout.rowGap, kind: kinds[segment.statement] ?? "process" };
      return `${arrow(segment, next, place, kinds)}${halo(segment, place, glow)}${node(segment, place, glow)}`;
    }).join("");
  }).join("");
}

type NodePlace = { readonly row: MuteLensRow; readonly unit: number; readonly kind: StatementKind };

function span(segment: CodeSegment, unit: number): number {
  return Math.min(segment.end - segment.start, unit * 3.1) * 0.7;
}

function halfWidth(segment: CodeSegment, place: NodePlace): number {
  return place.kind === "join" ? place.unit * 0.12 : span(segment, place.unit) / 2;
}

function node(segment: CodeSegment, place: NodePlace, glow: number): string {
  const { unit, kind, row } = place;
  const c = segment.center;
  const y = row.y;
  const half = span(segment, unit) / 2;
  const h = (kind === "decision" ? 0.67 : 0.46) * unit / 2;
  const stroke = `stroke="${mix(glow)}" stroke-width="${(unit * 0.042).toFixed(1)}" fill="${P.node}" stroke-linejoin="round"`;
  if (kind === "join") {
    return `<circle cx="${c}" cy="${y}" r="${unit * 0.12}" fill="${P.join}"/>`;
  }
  if (kind === "decision") {
    return `<path d="M${c - half} ${y} L${c} ${y - h} L${c + half} ${y} L${c} ${y + h} Z" ${stroke}/>`;
  }
  if (kind === "io") {
    const slant = h * 0.3;
    return `<path d="M${c - half + slant} ${y - h} L${c + half + slant} ${y - h} L${c + half - slant} ${y + h} L${c - half - slant} ${y + h} Z" ${stroke}/>`;
  }
  return `<rect x="${c - half}" y="${y - h}" width="${half * 2}" height="${h * 2}" rx="${kind === "terminal" ? h : unit * 0.07}" ${stroke}/>`;
}

function halo(segment: CodeSegment, place: NodePlace, glow: number): string {
  if (glow < 0.4) {
    return "";
  }
  const pad = place.unit * 0.21;
  const half = span(segment, place.unit) / 2 + pad;
  const h = place.unit * 0.33 + pad;
  return `<rect x="${segment.center - half}" y="${place.row.y - h}" width="${half * 2}" height="${h * 2}" rx="${pad * 1.3}" fill="rgba(${P.running.red},${P.running.green},${P.running.blue},${(0.28 * glow).toFixed(2)})" filter="url(#halo)"/>`;
}

function arrow(segment: CodeSegment, next: CodeSegment | undefined, place: NodePlace, kinds: readonly StatementKind[]): string {
  if (!next) {
    return "";
  }
  const from = segment.center + halfWidth(segment, place) + place.unit * 0.08;
  const to = next.center - halfWidth(next, { ...place, kind: kinds[next.statement] ?? "process" }) - place.unit * 0.18;
  if (to <= from) {
    return "";
  }
  const y = place.row.y;
  const head = place.unit * 0.065;
  return `<line x1="${from}" y1="${y}" x2="${to}" y2="${y}" stroke="${P.arrow}" stroke-width="${(place.unit * 0.03).toFixed(1)}"/><path d="M${to} ${y - head} L${to + head * 1.8} ${y} L${to} ${y + head} Z" fill="${P.arrow}"/>`;
}

function mix(glow: number): string {
  const { nodeStroke: a, running: b } = P;
  const channel = (from: number, to: number) => Math.round(from + (to - from) * glow);
  return `rgb(${channel(a.red, b.red)},${channel(a.green, b.green)},${channel(a.blue, b.blue)})`;
}
