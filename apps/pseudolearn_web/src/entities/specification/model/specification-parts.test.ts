import { describe, expect, it } from 'vitest';
import { isSpecificationSubject, specificationParts, specificationSubject } from './specification-parts';

describe('specificationParts', () => {
  it('lists the same parts in both languages', () => {
    expect(specificationParts('en').map((part) => part.id)).toEqual(
      specificationParts('es').map((part) => part.id),
    );
    expect(specificationParts('es').length).toBeGreaterThan(0);
  });

  it('accepts a published part as a contact subject', () => {
    const [part] = specificationParts('es');
    expect(part && isSpecificationSubject(specificationSubject(part))).toBe(true);
  });

  it('rejects bare ids, unknown parts and the old document ids', () => {
    const [part] = specificationParts('es');
    expect(isSpecificationSubject(part?.id ?? '')).toBe(false);
    expect(isSpecificationSubject('spec:parte-99')).toBe(false);
    expect(isSpecificationSubject('spec-lexical')).toBe(false);
  });
});
