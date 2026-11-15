import type { FigureBlock, FigureLayer, FigurePanel, Runs } from './specification';

const ROLE_COLORS: readonly string[] = [
  'var(--pl-ink)',
  'var(--pl-surface)',
  'var(--pl-syn-struct)',
  'var(--pl-syn-proc)',
  'var(--pl-syn-oop)',
  'var(--pl-syn-num)',
  'var(--pl-syn-str)',
  'var(--pl-syn-num)',
  'var(--pl-syn-str)',
  'var(--pl-danger)',
  'var(--pl-ink-3)',
  'var(--pl-syn-proc)',
  'var(--pl-syn-struct)',
];

const ROLE_SENTINEL = /"#FF00([0-9A-F]{2})"/gi;
const FONT_FAMILIES: Readonly<Record<string, string>> = {
  IBMPlexSans: 'IBM Plex Sans, sans-serif',
  IBMPlexMono: 'IBM Plex Mono, monospace',
};
const FONT_FAMILY = /font-family="(IBMPlexSans|IBMPlexMono)"/g;
const SVG_END = '</svg>';

export interface FigureFrame {
  readonly step: number;
  readonly svg: string;
  readonly runs: Runs;
  readonly zones: readonly PanelZone[];
}

export function themeFigure(svg: string): string {
  return svg
    .replace(ROLE_SENTINEL, (sentinel, role: string) => {
      const color = ROLE_COLORS[Number.parseInt(role, 16) - 1];
      return color === undefined ? sentinel : `"${color}"`;
    })
    .replace(FONT_FAMILY, (_attribute, family: string) => `font-family="${FONT_FAMILIES[family] ?? family}"`);
}

export function composeStep(base: string, layers: readonly FigureLayer[], step: number): string {
  const active = layers
    .filter((layer) => layer.from_step <= step && step <= (layer.until_step ?? Number.POSITIVE_INFINITY))
    .map((layer) => layer.svg)
    .join('');
  const end = base.lastIndexOf(SVG_END);
  return end < 0 ? base : `${base.slice(0, end)}${active}${base.slice(end)}`;
}

export function figureFrames(figure: FigureBlock): readonly FigureFrame[] {
  const steps = figure.steps.length === 0 ? [{ runs: [] }] : figure.steps;
  return steps.map((entry, index) => {
    const step = figure.steps.length === 0 ? Number.POSITIVE_INFINITY : index + 1;
    return {
      step: index + 1,
      svg: themeFigure(composeStep(figure.svg, figure.layers, step)),
      runs: entry.runs,
      zones: panelZones(figure.panels, step),
    };
  });
}

export interface PanelZone {
  readonly zone: string;
  readonly entries: readonly Runs[];
}

export function panelZones(panels: readonly FigurePanel[], step: number): readonly PanelZone[] {
  const zones = new Map<string, Runs[]>();
  for (const panel of panels.filter((candidate) => candidate.from_step <= step)) {
    zones.set(panel.zone, [...(zones.get(panel.zone) ?? []), panel.runs]);
  }
  return [...zones].map(([zone, entries]) => ({ zone, entries }));
}
