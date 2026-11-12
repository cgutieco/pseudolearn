import { describe, expect, it } from 'vitest';
import { plainRouteText, specificationRuns } from './route-runs';

describe('specificationRuns', () => {
  it('maps definitions and specification links onto the specification vocabulary', () => {
    expect(
      specificationRuns([
        { type: 'definition', term: 'salida', text: 'salida' },
        { type: 'spec_link', section: 'expresiones.division', text: 'la Especificación' },
        { type: 'strong', text: '9' },
      ]),
    ).toEqual([
      { type: 'term', term: 'salida', text: 'salida' },
      { type: 'link', section: 'expresiones.division', text: 'la Especificación' },
      { type: 'strong', text: '9' },
    ]);
  });

  it('keeps an empty run list empty', () => {
    expect(specificationRuns([])).toEqual([]);
  });
});

describe('plainRouteText', () => {
  it('joins text and code tokens', () => {
    expect(
      plainRouteText([
        { type: 'text', text: 'Usa ' },
        { type: 'code', tokens: [['techo', 'identifier'], ['(']] },
      ]),
    ).toBe('Usa techo(');
  });
});
