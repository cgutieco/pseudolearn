import { describe, expect, it } from 'vitest';
import { routeRunsHtml } from './route-html';

describe('routeRunsHtml', () => {
  it('links specification references to the localized section', () => {
    const html = routeRunsHtml(
      [{ type: 'spec_link', section: 'expresiones.division', text: 'la división' }],
      'en',
    );
    expect(html).toContain('href="/en/spec/expresiones/division"');
  });

  it('escapes text and keeps emphasis', () => {
    expect(routeRunsHtml([{ type: 'strong', text: '<9>' }], 'es')).toBe('<strong>&lt;9&gt;</strong>');
  });

  it('renders a definition as plain text', () => {
    expect(routeRunsHtml([{ type: 'definition', term: 'salida', text: 'salida' }], 'es')).toBe('salida');
  });
});
