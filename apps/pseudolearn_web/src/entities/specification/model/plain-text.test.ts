import { describe, expect, it } from 'vitest';
import { runsText, tokensText } from './plain-text';

describe('plain text', () => {
  it('joins token texts and every run kind', () => {
    expect(tokensText([['Si', 'keywordStructured'], [' '], ['x']])).toBe('Si x');
    expect(
      runsText([
        { type: 'text', text: 'La ' },
        { type: 'code', tokens: [['Si', 'keywordStructured']] },
        { type: 'link', section: 'a.b', text: ' 6.1' },
      ]),
    ).toBe('La Si 6.1');
  });

  it('returns an empty string for no tokens or runs', () => {
    expect(tokensText([])).toBe('');
    expect(runsText([])).toBe('');
  });
});
