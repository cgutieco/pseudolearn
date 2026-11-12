import { describe, expect, it } from 'vitest';
import { llmsFull, llmsIndex, plainText } from './llms';

describe('llms.txt', () => {
  it('indexes the full sheet with an absolute site path', () => {
    const index = llmsIndex();
    expect(index.startsWith('# PseudoLearn\n')).toBe(true);
    expect(index).toContain('(/llms-full.txt)');
    expect(index.endsWith('\n')).toBe(true);
  });

  it('lists the illustrated specification when links are given', () => {
    const index = llmsIndex(['- [Spec](/spec/index.md): contents']);
    expect(index).toContain('## Illustrated specification\n\n- [Spec](/spec/index.md): contents\n');
  });

  it('omits the specification heading without links', () => {
    expect(llmsIndex([])).not.toContain('## Illustrated specification');
  });

  it('publishes both generated sheets, English first', () => {
    const full = llmsFull();
    expect(full.indexOf('language sheet for agents')).toBeGreaterThanOrEqual(0);
    expect(full.indexOf('ficha del lenguaje para agentes')).toBeGreaterThan(
      full.indexOf('language sheet for agents'),
    );
    expect(full).toContain('Differences from PSeInt');
  });

  it('serves plain text', () => {
    expect(plainText['content-type']).toBe('text/plain; charset=utf-8');
  });
});
