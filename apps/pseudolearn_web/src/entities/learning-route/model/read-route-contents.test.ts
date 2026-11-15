import { describe, expect, it } from 'vitest';
import { readRouteContents } from './read-route-contents';

const lesson = { id: 'inicio.uno', minutes: 10, title: [{ type: 'text', text: 'Uno' }], exercises: [] };
const part = { id: 'parte-inicio', number: '0', title: 'Inicio', lessons: [lesson] };

describe('readRouteContents', () => {
  it('accepts well formed parts and lessons', () => {
    const reading = readRouteContents([part]);
    expect(reading.problems).toEqual([]);
    expect(reading.parts.map((candidate) => candidate.id)).toEqual(['parte-inicio']);
  });

  it('reports an empty or missing table of contents', () => {
    expect(readRouteContents([]).problems).toEqual([{ rule: 'ROUTE-CONTENTS-EMPTY', path: 'toc.json' }]);
    expect(readRouteContents(undefined).problems[0]?.rule).toBe('ROUTE-CONTENTS-EMPTY');
  });

  it('drops a malformed part and names its position', () => {
    const reading = readRouteContents([part, { id: 7 }]);
    expect(reading.parts).toHaveLength(1);
    expect(reading.problems).toEqual([{ rule: 'ROUTE-PART-SHAPE', path: 'toc.json[1]' }]);
  });

  it('reports a lesson without minutes', () => {
    const broken = { ...part, lessons: [{ ...lesson, minutes: 'ten' }] };
    expect(readRouteContents([broken]).problems).toEqual([
      { rule: 'ROUTE-LESSON-SHAPE', path: 'parte-inicio -> inicio.uno' },
    ]);
  });

  it('reports an exercise of an unknown kind', () => {
    const exercise = { id: 'inicio.uno.e', kind: 'adivinar', level: 'semilla', required: true, title: [] };
    const broken = { ...part, lessons: [{ ...lesson, exercises: [exercise] }] };
    expect(readRouteContents([broken]).problems).toEqual([
      { rule: 'ROUTE-EXERCISE-KIND', path: 'parte-inicio -> inicio.uno.e' },
    ]);
  });

  it('describes an anonymous broken lesson', () => {
    const broken = { ...part, lessons: [null] };
    expect(readRouteContents([broken]).problems[0]?.path).toBe('parte-inicio -> lesson');
  });
});
