import { describe, expect, it } from 'vitest';
import { blockRuns, linkedSections, nestedBlocks } from './block-runs';
import { sectionFixture } from '../testing/specification-fixtures';
import type { SpecificationBlock } from './specification';

const link = (section: string) => [{ type: 'link' as const, section, text: section }];

describe('linkedSections', () => {
  it('collects links from runs, nested callouts, figures, tables and see-also lists', () => {
    const blocks: SpecificationBlock[] = [
      { type: 'paragraph', runs: link('a.one') },
      {
        type: 'callout',
        kind: 'note',
        collapsible: false,
        blocks: [{ type: 'summary', points: [link('a.two')] }],
      },
      { type: 'table', header: [link('a.three')], rows: [[link('a.four')]] },
      { type: 'see_also', links: [{ section: 'a.five', number: '1', title: 'Five' }] },
      {
        type: 'figure',
        id: 'f',
        number: '1-1',
        alt: '',
        description: '',
        caption: link('a.six'),
        svg: '<svg></svg>',
        layers: [],
        steps: [{ runs: link('a.seven') }],
        panels: [{ zone: 'z', from_step: 1, runs: link('a.eight') }],
      },
    ];
    expect([...linkedSections(sectionFixture('a.zero', blocks))].sort()).toEqual(
      ['a.eight', 'a.five', 'a.four', 'a.one', 'a.seven', 'a.six', 'a.three', 'a.two'].sort(),
    );
  });

  it('reports each target once and nothing for a section without links', () => {
    const repeated = sectionFixture('a.zero', [
      { type: 'paragraph', runs: link('a.one') },
      { type: 'paragraph', runs: link('a.one') },
    ]);
    expect(linkedSections(repeated)).toEqual(['a.one']);
    expect(linkedSections(sectionFixture('a.zero'))).toEqual([]);
  });

  it('flattens deeply nested callouts and gives no runs to code-only blocks', () => {
    const deep: SpecificationBlock = {
      type: 'callout',
      kind: 'inside',
      collapsible: true,
      blocks: [
        { type: 'callout', kind: 'note', collapsible: false, blocks: [{ type: 'paragraph', runs: [] }] },
      ],
    };
    expect(nestedBlocks([deep]).map((block) => block.type)).toEqual(['callout', 'callout', 'paragraph']);
    expect(blockRuns({ type: 'intermediate', program: 'p', lines: ['x'] })).toEqual([]);
  });
});
