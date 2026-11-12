import { describe, expect, it } from 'vitest';
import { runsHtml } from './runs-html';

const hrefFor = (sectionId: string) => `/spec/${sectionId.replace('.', '/')}`;

describe('runsHtml', () => {
  it('renders every run kind without extra whitespace', () => {
    const html = runsHtml(
      [
        { type: 'text', text: 'Usa ' },
        { type: 'code', tokens: [['Si', 'keywordStructured']] },
        { type: 'text', text: ', ' },
        { type: 'strong', text: 'siempre' },
        { type: 'emphasis', text: 'nunca' },
        { type: 'slot', text: 'condición' },
        { type: 'link', section: 'control.si', text: '6.1' },
        { type: 'term', term: 'algoritmo', text: 'algoritmo' },
      ],
      hrefFor,
    );
    expect(html).toBe(
      'Usa <code class="runs__code"><span class="code__token code__token--structured">Si</span></code>, ' +
        '<strong>siempre</strong><em>nunca</em><span class="runs__slot">«condición»</span>' +
        '<a class="runs__link" href="/spec/control/si">6.1</a>algoritmo',
    );
  });

  it('escapes text so content never becomes markup', () => {
    expect(runsHtml([{ type: 'text', text: '<script>' }], hrefFor)).toBe('&lt;script&gt;');
    expect(runsHtml([{ type: 'link', section: 'a.b', text: '"x"' }], () => '/a"b')).toBe(
      '<a class="runs__link" href="/a&quot;b">&quot;x&quot;</a>',
    );
  });

  it('renders no runs as an empty string', () => {
    expect(runsHtml([], hrefFor)).toBe('');
  });
});
