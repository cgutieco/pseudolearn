import { copiesToCover, type LensLayout, type LensRow, type LensSegment } from "../layout/lens_layout.ts";
import { escapeHtml } from "./html_text.ts";

type Placed = { readonly segment: LensSegment; readonly center: number };

export function riverMarkup(layout: LensLayout): string {
  return layout.rows.map((row, index) => {
    const copies = copiesToCover(row, layout.canvas.width);
    const texts: string[] = [];
    for (let copy = 0; copy < copies; copy += 1) {
      for (const segment of row.segments) {
        texts.push(`<div class="code" style="left:${copy * row.tile + segment.start}px;top:${row.y - layout.monoSize * 0.62}px">${escapeHtml(segment.text)}</div>`);
      }
    }
    return `<div class="row" ${rowData(row, index)}>${texts.join("")}</div>`;
  }).join("\n");
}

export function diagramMarkup(layout: LensLayout, shapes: readonly string[]): string {
  return layout.rows.map((row, index) => {
    const placed: Placed[] = [];
    for (let copy = 0; copy < copiesToCover(row, layout.canvas.width); copy += 1) {
      row.segments.forEach((segment) => placed.push({ segment, center: copy * row.tile + segment.center }));
    }
    const nodes = placed.map((item, at) => nodeMarkup(item, { next: placed[at + 1], y: row.y - layout.lens.y, unit: layout.unit, shape: shapes[item.segment.statement] ?? "process" })).join("");
    return `<div class="row" ${rowData(row, index)}><div class="shift" style="left:${-layout.lens.x}px">${nodes}</div></div>`;
  }).join("\n");
}

function rowData(row: LensRow, index: number): string {
  return `data-row="${index}" data-tile="${row.tile}" data-phase="${row.phase}"`;
}

type NodeContext = { readonly next: Placed | undefined; readonly y: number; readonly unit: number; readonly shape: string };

function nodeMarkup(item: Placed, context: NodeContext): string {
  const { segment, center } = item;
  const half = segment.nodeWidth / 2;
  const label = segment.form === "dot" ? "" : `<span>${escapeHtml(segment.text)}</span>`;
  const node = `<div class="node ${context.shape}" data-center="${center}" style="left:${center - half}px;top:${context.y - segment.nodeHeight / 2}px;width:${segment.nodeWidth}px;height:${segment.nodeHeight}px">${label}</div>`;
  const next = context.next;
  if (!next) {
    return node;
  }
  const from = center + half + 8 * context.unit;
  const to = next.center - next.segment.nodeWidth / 2 - 30 * context.unit;
  return `${node}<div class="arrow" style="left:${from}px;top:${context.y - 2 * context.unit}px;width:${Math.max(0, to - from)}px"></div>`;
}
