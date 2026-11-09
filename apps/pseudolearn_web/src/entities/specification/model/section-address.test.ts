import { describe, expect, it } from 'vitest';
import { sectionAddress, sectionIdOf, sectionPath, sectionSlug } from './section-address';

describe('section addresses', () => {
  it('splits an area.topic id into a two-level address', () => {
    expect(sectionAddress('control.si')).toEqual({ area: 'control', topic: 'si' });
    expect(sectionIdOf({ area: 'control', topic: 'si' })).toBe('control.si');
    expect(sectionSlug('tipos.opcional-resultado')).toBe('tipos/opcional-resultado');
    expect(sectionPath('control.si')).toBe('/spec/control/si');
  });

  it('accepts one-character components', () => {
    expect(sectionAddress('a.b')).toEqual({ area: 'a', topic: 'b' });
  });

  it('rejects ids that cannot become a two-level path', () => {
    for (const id of ['', 'control', 'a.b.c', '.si', 'control.', 'Control.Si', 'con trol.si']) {
      expect(sectionAddress(id), id).toBeNull();
    }
  });

  it('keeps an unaddressable id unchanged as its slug', () => {
    expect(sectionSlug('control')).toBe('control');
  });
});
