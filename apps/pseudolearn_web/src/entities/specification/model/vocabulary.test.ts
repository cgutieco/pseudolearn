import { describe, expect, it } from 'vitest';
import type { SpecificationSection } from './specification';
import { VOCABULARY_SECTION, pickPairs, vocabularyPairs } from './vocabulary';
import { findSection } from './specification-catalog';

function section(rows: SpecificationSection['blocks']): SpecificationSection {
  return { id: VOCABULARY_SECTION, number: 'B', blocks: rows } as unknown as SpecificationSection;
}

const code = (text: string, category: string) => [{ type: 'code', tokens: [[text, category]] }];

describe('vocabularyPairs', () => {
  it('pairs keywords of both profiles with their tone', () => {
    const table = {
      type: 'table',
      header: [],
      rows: [
        [code('Mientras', 'keywordStructured'), code('While', 'keywordStructured'), []],
        [code('Clase', 'keywordOop'), code('Class', 'keywordOop'), []],
      ],
    };
    expect(vocabularyPairs(section([table] as never))).toEqual([
      { spanish: 'Mientras', english: 'While', tone: 'structured' },
      { spanish: 'Clase', english: 'Class', tone: 'object' },
    ]);
  });

  it('skips signs, types and cells that are not a single keyword', () => {
    const table = {
      type: 'table',
      header: [],
      rows: [
        [code('+', 'operator'), code('+', 'operator'), []],
        [code('Entero', 'type'), code('Integer', 'type'), []],
        [[{ type: 'text', text: 'x' }], code('While', 'keywordStructured'), []],
      ],
    };
    expect(vocabularyPairs(section([table] as never))).toEqual([]);
  });

  it('returns nothing without a section or a table', () => {
    expect(vocabularyPairs(undefined)).toEqual([]);
    expect(vocabularyPairs(section([]))).toEqual([]);
  });

  it('reads the published reserved words of both editions', () => {
    const pairs = vocabularyPairs(findSection('en', VOCABULARY_SECTION));
    expect(pickPairs(pairs, ['Mientras'])).toEqual([
      { spanish: 'Mientras', english: 'While', tone: 'structured' },
    ]);
    expect(pickPairs(pairs, ['NoExiste'])).toEqual([]);
  });
});
