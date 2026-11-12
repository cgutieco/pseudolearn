import { describe, expect, it } from 'vitest';
import { buildFooterColumns, buildNavigation, downloadLink, isCurrentSection } from './navigation';

describe('buildNavigation', () => {
  it('links only to pages, never to anchors', () => {
    const links = buildNavigation('es');
    expect(links.map((link) => link.href)).toEqual(['/language', '/learn', '/nodo', '/spec']);
    expect(links.every((link) => !link.href.includes('#'))).toBe(true);
  });

  it('prefixes every page in english', () => {
    expect(buildNavigation('en').map((link) => link.href)).toEqual([
      '/en/language',
      '/en/learn',
      '/en/nodo',
      '/en/spec',
    ]);
    expect(downloadLink('en').href).toBe('/en/download');
  });
});

describe('isCurrentSection', () => {
  it('matches a page and its subpages', () => {
    expect(isCurrentSection('/spec', '/spec')).toBe(true);
    expect(isCurrentSection('/spec/control/si', '/spec')).toBe(true);
  });

  it('does not confuse pages that share a prefix', () => {
    expect(isCurrentSection('/learning', '/learn')).toBe(false);
    expect(isCurrentSection('/', '/learn')).toBe(false);
  });
});

describe('buildFooterColumns', () => {
  it('lists each destination once', () => {
    const hrefs = buildFooterColumns('es').flatMap((column) => column.links.map((link) => link.href));
    expect(new Set(hrefs).size).toBe(hrefs.length);
  });
});
