import { describe, expect, it } from 'vitest';
import { FORMATS, mediaQueryFor } from './picture-media';

describe('mediaQueryFor', () => {
  it('combines breakpoint and colour scheme for the desktop source', () => {
    expect(mediaQueryFor('(min-width: 900px)', 'dark')).toBe(
      '(min-width: 900px) and (prefers-color-scheme: dark)',
    );
  });

  it('leaves the mobile source as the unconstrained fallback of the picture', () => {
    expect(mediaQueryFor('all', 'light')).toBe('(prefers-color-scheme: light)');
  });

  it('serves modern formats only', () => {
    expect(FORMATS).toEqual(['avif', 'webp']);
  });
});
