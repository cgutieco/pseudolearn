import { describe, expect, it } from 'vitest';
import { findSection, orderedSections, specificationEdition } from './specification-catalog';
import { sectionAddress } from './section-address';

describe('published specification', () => {
  it('loads both editions with the same sections in the same order', () => {
    const spanish = orderedSections('es').map((entry) => entry.id);
    const english = orderedSections('en').map((entry) => entry.id);
    expect(spanish.length).toBeGreaterThan(50);
    expect(english).toEqual(spanish);
  });

  it('gives every section a two-level web address and a body', () => {
    for (const entry of orderedSections('es')) {
      expect(sectionAddress(entry.id), entry.id).not.toBeNull();
      expect(findSection('es', entry.id)?.blocks.length, entry.id).toBeGreaterThan(0);
    }
  });

  it('keeps heading anchors unique inside each section', () => {
    for (const section of specificationEdition('es').sections.values()) {
      const anchors = section.blocks.flatMap((block) => (block.type === 'heading' ? [block.id] : []));
      expect(new Set(anchors).size, section.id).toBe(anchors.length);
    }
  });

  it('answers an unknown section with undefined', () => {
    expect(findSection('es', 'no.existe')).toBeUndefined();
  });
});
