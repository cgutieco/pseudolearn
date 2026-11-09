import { describe, expect, it } from 'vitest';
import { contentsMarkdown, sectionMarkdown, type DocumentContext } from './section-markdown';
import { contentsFixture, LABELS_FIXTURE, sectionFixture } from '../testing/specification-fixtures';
import type { SpecificationBlock } from './specification';

const context: DocumentContext = {
  labels: LABELS_FIXTURE,
  sectionHref: (id) => `https://example.test/${id}.md`,
  pageUrl: 'https://example.test/page',
};

const program: SpecificationBlock = {
  type: 'program',
  id: 'p',
  title: 'Sum',
  source: 'Algoritmo S\nFinAlgoritmo\n',
  lines: [],
  executed: true,
  inputs: ['3'],
  output: '3\n',
  termination: 'failed',
  diagnostics: [
    { code: 'divisionByZero', severity: 'error', line: 2, column: 5, message: 'Division by zero' },
  ],
};

describe('sectionMarkdown', () => {
  it('starts with the numbered title, the phrase and the web page', () => {
    const text = sectionMarkdown(sectionFixture('a.one'), context);
    expect(text).toBe('# 1.1 Title a.one\n\n> Phrase a.one\n\nWeb page: https://example.test/page\n\n\n');
  });

  it('renders programs with input, output, diagnostics and termination', () => {
    const text = sectionMarkdown(sectionFixture('a.one', [program]), context);
    expect(text).toContain('### Program: Sum\n\n```pseudolearn\nAlgoritmo S\nFinAlgoritmo\n```');
    expect(text).toContain('**Input**\n\n```text\n3\n```');
    expect(text).toContain('**Output**\n\n```text\n3\n```');
    expect(text).toContain('- `divisionByZero` (error, 2:5): Division by zero');
    expect(text).toContain('*Failed*');
  });

  it('omits empty input, output and diagnostics of a program', () => {
    const silent = { ...program, inputs: undefined, output: '', diagnostics: [], termination: '' as const };
    const text = sectionMarkdown(sectionFixture('a.one', [silent]), context);
    expect(text).not.toContain('**Input**');
    expect(text).not.toContain('**Output**');
    expect(text).not.toContain('**Diagnostics**');
    expect(text).toContain('*Not run*');
  });

  it('quotes callouts, numbers headings and writes tables, forms and figures', () => {
    const blocks: SpecificationBlock[] = [
      { type: 'heading', id: 'funciona', number: '1.1.1', runs: [{ type: 'text', text: 'How' }] },
      {
        type: 'callout',
        kind: 'limit',
        collapsible: false,
        blocks: [{ type: 'paragraph', runs: [{ type: 'text', text: 'Careful' }] }],
      },
      { type: 'table', header: [[{ type: 'text', text: 'A' }]], rows: [[[{ type: 'text', text: 'x|y' }]]] },
      {
        type: 'form',
        lines: [
          [
            { type: 'token', token: ['Leer', 'keywordStructured'] },
            { type: 'token', token: [' '] },
            { type: 'slot', text: 'destino' },
          ],
        ],
      },
      { type: 'list', ordered: true, entries: [[{ type: 'text', text: 'first' }]] },
      {
        type: 'figure',
        id: 'f',
        number: '1.1-1',
        alt: 'Stack',
        description: 'A stack',
        caption: [{ type: 'text', text: 'Caption' }],
        svg: '<svg></svg>',
        layers: [],
        steps: [{ runs: [{ type: 'text', text: 'push' }] }],
        panels: [],
      },
      { type: 'trace', program: 'p', events: [{ line: 4, class: 'output', detail: 'writes | ok' }] },
    ];
    const text = sectionMarkdown(sectionFixture('a.one', blocks), context);
    expect(text).toContain('## 1.1.1 How');
    expect(text).toContain('> **Limit**\n>\n> Careful');
    expect(text).toContain('| A |\n| --- |\n| x\\|y |');
    expect(text).toContain('```pseudolearn\nLeer «destino»\n```');
    expect(text).toContain('1. first');
    expect(text).toContain('**Figure 1.1-1: Stack**\n\nA stack\n\nCaption\n\n1. Step 1: push');
    expect(text).toContain('| 4 | writes \\| ok |');
  });
});

describe('contentsMarkdown', () => {
  it('lists every part and section with Markdown links', () => {
    const text = contentsMarkdown(
      contentsFixture('a.one', 'a.two'),
      { title: 'Spec', lead: 'Lead' },
      context,
    );
    expect(text.startsWith('# Spec\n\n> Lead\n\nWeb page: https://example.test/page\n\n## 1. Part')).toBe(
      true,
    );
    expect(text).toContain('- [1.1 Title a.one](https://example.test/a.one.md): Phrase a.one');
    expect(text).toContain('- [1.1 Title a.two](https://example.test/a.two.md): Phrase a.two');
  });

  it('writes only the heading for an edition without parts', () => {
    expect(contentsMarkdown([], { title: 'Spec', lead: 'Lead' }, context)).toBe(
      '# Spec\n\n> Lead\n\nWeb page: https://example.test/page\n',
    );
  });
});
