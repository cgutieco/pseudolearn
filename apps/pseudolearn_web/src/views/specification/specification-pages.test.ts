import { describe, expect, it } from 'vitest';
import {
  contentsMarkdownPath,
  contentsMarkdownResponse,
  sectionContext,
  sectionMarkdownPath,
  sectionMarkdownResponse,
  sectionStaticPaths,
  specificationAgentLinks,
  specificationSitemapPaths,
} from './specification-pages';

describe('specification pages', () => {
  it('builds one static path per section with its two-level address', () => {
    const paths = sectionStaticPaths('es');
    expect(paths[0]).toEqual({
      params: { area: 'lectura', topic: 'contenido' },
      props: { sectionId: 'lectura.contenido' },
    });
    expect(sectionStaticPaths('en')).toHaveLength(paths.length);
  });

  it('finds neighbours, with none before the first and none after the last', () => {
    const ids = sectionStaticPaths('es').map((path) => path.props.sectionId);
    const first = sectionContext('es', ids[0] ?? '');
    const last = sectionContext('es', ids.at(-1) ?? '');
    expect(first.previous).toBeUndefined();
    expect(first.next?.id).toBe(ids[1]);
    expect(last.next).toBeUndefined();
    expect(first.part.sections.some((entry) => entry.id === ids[0])).toBe(true);
  });

  it('fails loudly for a section that does not exist', () => {
    expect(() => sectionContext('es', 'no.existe')).toThrow('Unknown specification section: no.existe');
  });

  it('places the Markdown versions next to each localized page', () => {
    expect(sectionMarkdownPath('es', 'control.si')).toBe('/spec/control/si.md');
    expect(sectionMarkdownPath('en', 'control.si')).toBe('/en/spec/control/si.md');
    expect(contentsMarkdownPath('es')).toBe('/spec/index.md');
    expect(contentsMarkdownPath('en')).toBe('/en/spec/index.md');
  });

  it('serves section Markdown with absolute links to other Markdown sections', async () => {
    const response = sectionMarkdownResponse('en', 'control.si');
    const text = await response.text();
    expect(response.headers.get('content-type')).toBe('text/markdown; charset=utf-8');
    expect(text.startsWith('# 6.1 ')).toBe(true);
    expect(text).toContain('Web page: https://pseudolearn.app/en/spec/control/si');
    expect(text).toMatch(/\]\(https:\/\/pseudolearn\.app\/en\/spec\/[a-z-]+\/[a-z-]+\.md\)/);
  });

  it('serves the contents in Markdown for each language', async () => {
    const spanish = await contentsMarkdownResponse('es').text();
    expect(spanish.startsWith('# Especificación del lenguaje')).toBe(true);
    expect(spanish).toContain('(https://pseudolearn.app/spec/control/si.md)');
  });

  it('lists every section once for the sitemap and both indexes for agents', () => {
    const paths = specificationSitemapPaths();
    expect(new Set(paths).size).toBe(paths.length);
    expect(paths).toContain('/spec/control/si');
    expect(specificationAgentLinks()).toEqual([
      expect.stringContaining('(/spec/index.md)'),
      expect.stringContaining('(/en/spec/index.md)'),
    ]);
  });
});
