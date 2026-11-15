import { describe, expect, it } from 'vitest';
import { composeStep, figureFrames, panelZones, themeFigure } from './figure-frames';
import type { FigureBlock } from './specification';

const BASE = '<svg viewBox="0 0 340 100"><rect fill="#FF0002" stroke="#FF0001"/></svg>';

function figure(overrides: Partial<FigureBlock> = {}): FigureBlock {
  return {
    type: 'figure',
    id: 'f',
    number: '1-1',
    alt: 'Alt',
    description: 'Description',
    caption: [],
    svg: BASE,
    layers: [],
    steps: [],
    panels: [],
    ...overrides,
  };
}

describe('themeFigure', () => {
  it('replaces every role sentinel with a theme variable and maps font names', () => {
    const themed = themeFigure('<text fill="#FF000D" stroke="#ff000a" font-family="IBMPlexMono">x</text>');
    expect(themed).toBe(
      '<text fill="var(--pl-syn-struct)" stroke="var(--pl-danger)" font-family="IBM Plex Mono, monospace">x</text>',
    );
  });

  it('leaves unknown sentinels and ordinary colours untouched', () => {
    expect(themeFigure('<rect fill="#FF0000" stroke="#FF000E" color="#123456"/>')).toBe(
      '<rect fill="#FF0000" stroke="#FF000E" color="#123456"/>',
    );
  });
});

describe('composeStep', () => {
  const layers = [
    { from_step: 1, svg: '<g id="one"/>' },
    { from_step: 2, until_step: 2, svg: '<g id="two"/>' },
  ];

  it('adds the layers active at a step before the closing tag', () => {
    expect(composeStep(BASE, layers, 1)).toContain('<g id="one"/></svg>');
    expect(composeStep(BASE, layers, 2)).toContain('<g id="one"/><g id="two"/></svg>');
    expect(composeStep(BASE, layers, 3)).not.toContain('id="two"');
  });

  it('keeps the base unchanged without layers or closing tag', () => {
    expect(composeStep(BASE, [], 1)).toBe(BASE);
    expect(composeStep('<svg>', layers, 1)).toBe('<svg>');
  });
});

describe('figureFrames', () => {
  it('produces one themed frame for a figure without steps', () => {
    const frames = figureFrames(figure());
    expect(frames).toHaveLength(1);
    expect(frames[0]?.svg).toContain('var(--pl-surface)');
    expect(frames[0]?.runs).toEqual([]);
  });

  it('produces one frame per step with its own layers and panels', () => {
    const frames = figureFrames(
      figure({
        layers: [{ from_step: 2, svg: '<g id="late"/>' }],
        steps: [{ runs: [{ type: 'text', text: 'first' }] }, { runs: [{ type: 'text', text: 'second' }] }],
        panels: [{ zone: 'Memory', from_step: 2, runs: [{ type: 'text', text: 'x = 1' }] }],
      }),
    );
    expect(frames.map((frame) => frame.step)).toEqual([1, 2]);
    expect(frames[0]?.svg).not.toContain('late');
    expect(frames[1]?.svg).toContain('late');
    expect(frames[0]?.zones).toEqual([]);
    expect(frames[1]?.zones.map((zone) => zone.zone)).toEqual(['Memory']);
  });
});

describe('panelZones', () => {
  it('accumulates the panels of each zone in order up to the step', () => {
    const text = (value: string) => [{ type: 'text' as const, text: value }];
    const panels = [
      { zone: 'Memory', from_step: 1, runs: text('a') },
      { zone: 'Trace', from_step: 2, runs: text('b') },
      { zone: 'Memory', from_step: 2, runs: text('c') },
    ];
    expect(panelZones(panels, 2)).toEqual([
      { zone: 'Memory', entries: [text('a'), text('c')] },
      { zone: 'Trace', entries: [text('b')] },
    ]);
    expect(panelZones(panels, 0)).toEqual([]);
  });
});
