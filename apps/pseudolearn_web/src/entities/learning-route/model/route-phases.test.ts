import { describe, expect, it } from 'vitest';
import type { RouteBlock } from './route';
import { asSentence, paradigmQuestion, phaseBlocks, phaseList, summaryPoints } from './route-phases';

const plan: RouteBlock = { type: 'list', ordered: true, entries: [[{ type: 'text', text: 'Multiplica' }]] };
const BLOCKS: readonly RouteBlock[] = [
  { type: 'cycle', phases: [1] },
  { type: 'paragraph', runs: [{ type: 'text', text: 'Entender' }] },
  { type: 'cycle', phases: [2] },
  plan,
  { type: 'cycle', phases: [3] },
  { type: 'paradigm', question: [{ type: 'text', text: '¿y si nada cambiara?' }], metaphor: [] },
];

describe('phaseBlocks', () => {
  it('returns the blocks between a phase and the next one', () => {
    expect(phaseBlocks(BLOCKS, 2)).toEqual([plan]);
  });

  it('runs to the end for the last phase and is empty for a missing one', () => {
    expect(phaseBlocks(BLOCKS, 3)).toHaveLength(1);
    expect(phaseBlocks(BLOCKS, 9)).toEqual([]);
  });
});

describe('phaseList and paradigmQuestion', () => {
  it('extracts the plan of a phase and the paradigm question', () => {
    expect(phaseList(BLOCKS, 2)).toEqual(plan.type === 'list' ? plan.entries : []);
    expect(paradigmQuestion(BLOCKS)).toEqual([{ type: 'text', text: '¿y si nada cambiara?' }]);
  });

  it('returns nothing when a phase has no list or a lesson has no paradigm', () => {
    expect(phaseList(BLOCKS, 1)).toEqual([]);
    expect(paradigmQuestion([])).toEqual([]);
  });
});

describe('summaryPoints', () => {
  it('returns the points of the lesson summary', () => {
    const points = [[{ type: 'text' as const, text: 'Un problema tiene datos' }]];
    expect(summaryPoints([...BLOCKS, { type: 'summary', points }])).toEqual(points);
  });

  it('returns nothing without a summary', () => {
    expect(summaryPoints(BLOCKS)).toEqual([]);
  });
});

describe('asSentence', () => {
  it('capitalizes the first letter after opening punctuation', () => {
    expect(asSentence('¿y si nada cambiara?')).toBe('¿Y si nada cambiara?');
    expect(asSentence('what if nothing changed?')).toBe('What if nothing changed?');
  });

  it('leaves text without letters untouched', () => {
    expect(asSentence('')).toBe('');
    expect(asSentence('¿?')).toBe('¿?');
  });
});
