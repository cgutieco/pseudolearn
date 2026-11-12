import { describe, expect, it } from 'vitest';
import type { SpecificationEdition, SpecificationSection } from './specification';
import { specificationFigures } from './specification-figures';
import { specificationEdition } from './specification-catalog';

function edition(blocks: unknown[]): SpecificationEdition {
  const section = { id: 'a.b', number: '1.1', blocks } as unknown as SpecificationSection;
  return { contents: [], sections: new Map([[section.id, section]]) } as unknown as SpecificationEdition;
}

describe('specificationFigures', () => {
  it('counts executed programs and figures, also inside nested blocks', () => {
    const figures = specificationFigures(
      edition([
        { type: 'program', executed: true },
        { type: 'program', executed: false },
        { type: 'callout', blocks: [{ type: 'figure' }, { type: 'program', executed: true }] },
      ]),
    );
    expect(figures).toEqual({ parts: 0, sections: 1, programs: 2, figures: 1 });
  });

  it('returns zeros for an empty edition', () => {
    const empty = { contents: [], sections: new Map() } as unknown as SpecificationEdition;
    expect(specificationFigures(empty)).toEqual({ parts: 0, sections: 0, programs: 0, figures: 0 });
  });

  it('measures the published edition', () => {
    const figures = specificationFigures(specificationEdition('es'));
    expect(figures.sections).toBeGreaterThan(100);
    expect(figures.programs).toBeGreaterThan(0);
  });
});
