import { describe, expect, it } from 'vitest';
import { createTranslator } from '@shared/i18n/translator';
import { markdownLabels } from './markdown-labels';

describe('markdownLabels', () => {
  it('translates every label into the requested language', () => {
    const spanish = markdownLabels(createTranslator('es'));
    const english = markdownLabels(createTranslator('en'));
    expect(spanish.callouts.errors).toBe('Errores frecuentes');
    expect(english.terminations['']).toBe('This program is not run.');
    expect(english.terminations.awaiting_input).toBe('The program is left waiting for input.');
  });

  it('never falls back to a raw key', () => {
    const english = markdownLabels(createTranslator('en'));
    const texts = [
      ...Object.values(english.callouts),
      ...Object.values(english.terminations),
      english.webPage,
    ];
    expect(texts.filter((text) => text.startsWith('specification.'))).toEqual([]);
  });
});
