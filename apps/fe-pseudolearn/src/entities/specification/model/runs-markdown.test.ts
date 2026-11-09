import { describe, expect, it } from 'vitest';
import { codeFence, inlineCode, runsMarkdown, tableCell } from './runs-markdown';

const href = (id: string) => `https://example.test/${id}.md`;

describe('runsMarkdown', () => {
  it('writes every run kind as Markdown', () => {
    expect(
      runsMarkdown(
        [
          { type: 'text', text: 'Usa ' },
          { type: 'code', tokens: [['Si', 'keywordStructured']] },
          { type: 'strong', text: 'siempre' },
          { type: 'emphasis', text: 'nunca' },
          { type: 'slot', text: 'hueco' },
          { type: 'link', section: 'control.si', text: '6.1' },
          { type: 'term', term: 't', text: 'término' },
        ],
        href,
      ),
    ).toBe('Usa `Si`**siempre***nunca*«hueco»[6.1](https://example.test/control.si.md)término');
  });

  it('writes nothing for no runs', () => {
    expect(runsMarkdown([], href)).toBe('');
  });
});

describe('inlineCode', () => {
  it('widens the fence when the code holds a backtick', () => {
    expect(inlineCode('a`b')).toBe('``a`b``');
    expect(inlineCode('`x')).toBe('`` `x ``');
  });
});

describe('codeFence', () => {
  it('drops trailing blank lines and switches fences around embedded fences', () => {
    expect(codeFence('text', ['a\n\n'])).toBe('```text\na\n```');
    expect(codeFence('', ['```'])).toBe('~~~~\n```\n~~~~');
    expect(codeFence('text', [])).toBe('```text\n\n```');
  });
});

describe('tableCell', () => {
  it('escapes pipes and keeps a cell on one line', () => {
    expect(tableCell('a | b\nc')).toBe('a \\| b c');
  });
});
