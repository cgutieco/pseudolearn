import { describe, expect, it } from 'vitest';
import type { RouteBlock, RoutePart } from './route';
import {
  attemptAnswer,
  firstExerciseOfKind,
  firstLesson,
  paragraphRuns,
  problemBlocks,
} from './route-samples';

const PARTS: readonly RoutePart[] = [
  {
    id: 'a',
    number: '0',
    title: 'A',
    motto: '',
    summary: '',
    lessons: [
      {
        id: 'a.uno',
        number: '0.1',
        kind: 'leccion',
        title: [],
        brief_problem: '',
        minutes: 10,
        exercises: [{ id: 'a.uno.e', kind: 'romperlo', level: 'brote', required: true, title: [] }],
      },
    ],
  },
];

describe('lesson selection', () => {
  it('starts with the first lesson of the route', () => {
    expect(firstLesson(PARTS).id).toBe('a.uno');
  });

  it('refuses an empty route', () => {
    expect(() => firstLesson([])).toThrow();
  });

  it('finds the first exercise of a kind or nothing', () => {
    expect(firstExerciseOfKind(PARTS, 'romperlo')?.id).toBe('a.uno.e');
    expect(firstExerciseOfKind(PARTS, 'ordenar')).toBeUndefined();
  });
});

describe('lesson blocks', () => {
  const paragraph: RouteBlock = { type: 'paragraph', runs: [{ type: 'text', text: 'Hola' }] };
  const blocks: readonly RouteBlock[] = [
    { type: 'problem', blocks: [paragraph] },
    { type: 'attempt', prompt: [], answer: [paragraph] },
  ];

  it('extracts the problem, the answer and their paragraphs', () => {
    expect(problemBlocks(blocks)).toEqual([paragraph]);
    expect(attemptAnswer(blocks)).toEqual([paragraph]);
    expect(paragraphRuns(problemBlocks(blocks))).toEqual([paragraph.runs]);
  });

  it('returns nothing when a lesson lacks a problem or an attempt', () => {
    expect(problemBlocks([])).toEqual([]);
    expect(attemptAnswer([paragraph])).toEqual([]);
  });
});
