import { describe, expect, it } from 'vitest';
import { codeLinesHtml, escapeHtml, formLineHtml, tokensHtml } from './token-html';

describe('tokensHtml', () => {
  it('wraps each token with the tone of its category', () => {
    expect(tokensHtml([['Si', 'keywordStructured'], [' '], ['x', 'identifier']])).toBe(
      '<span class="code__token code__token--structured">Si</span>' +
        '<span class="code__token code__token--plain"> </span>' +
        '<span class="code__token code__token--identifier">x</span>',
    );
  });

  it('escapes markup inside token text', () => {
    expect(tokensHtml([['a < b && "c"', 'operator']])).toContain('a &lt; b &amp;&amp; &quot;c&quot;');
  });

  it('renders nothing for no tokens', () => {
    expect(tokensHtml([])).toBe('');
  });
});

describe('formLineHtml', () => {
  it('marks slots and optional brackets apart from tokens', () => {
    const html = formLineHtml([
      { type: 'token', token: ['Leer', 'keywordStructured'] },
      { type: 'optional', text: '⟦' },
      { type: 'slot', text: 'destino' },
      { type: 'optional', text: '⟧' },
    ]);
    expect(html).toBe(
      '<span class="code__token code__token--structured">Leer</span>' +
        '<span class="code__optional">⟦</span>' +
        '<span class="code__slot">«destino»</span>' +
        '<span class="code__optional">⟧</span>',
    );
  });

  it('renders an empty line as an empty string', () => {
    expect(formLineHtml([])).toBe('');
  });
});

describe('escapeHtml', () => {
  it('escapes the five markup characters and keeps the rest', () => {
    expect(escapeHtml(`<&>"'ñ`)).toBe('&lt;&amp;&gt;&quot;&#39;ñ');
  });
});

describe('codeLinesHtml', () => {
  it('wraps each rendered line and joins them with newlines', () => {
    expect(codeLinesHtml(['a', '', 'b'])).toBe(
      '<span class="code__line">a</span>\n<span class="code__line"></span>\n<span class="code__line">b</span>',
    );
  });

  it('renders no lines as an empty string', () => {
    expect(codeLinesHtml([])).toBe('');
  });
});
