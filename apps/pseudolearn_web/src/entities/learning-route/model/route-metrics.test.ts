import { describe, expect, it } from 'vitest';
import type { ExerciseKind, RouteExerciseEntry, RouteLessonEntry, RoutePart } from './route';
import { hoursOf, routeMetrics, totalMinutes } from './route-metrics';

function exercise(kind: ExerciseKind, required: boolean): RouteExerciseEntry {
  return { id: `${kind}-${String(required)}`, kind, level: 'semilla', required, title: [] };
}

function lesson(
  minutes: number,
  exercises: readonly RouteExerciseEntry[],
  kind = 'leccion',
): RouteLessonEntry {
  return {
    id: `l${minutes}`,
    number: '0',
    kind: kind as RouteLessonEntry['kind'],
    title: [],
    brief_problem: '',
    minutes,
    exercises,
  };
}

const PARTS: readonly RoutePart[] = [
  {
    id: 'a',
    number: '0',
    title: 'A',
    motto: '',
    summary: '',
    lessons: [lesson(30, [exercise('resolver', true)])],
  },
  {
    id: 'b',
    number: 'I',
    title: 'B',
    motto: '',
    summary: '',
    lessons: [lesson(60, [exercise('resolver', false), exercise('predecir', true)], 'proyecto')],
  },
];

describe('routeMetrics', () => {
  it('counts parts, lessons, projects and exercises', () => {
    const metrics = routeMetrics(PARTS);
    expect(metrics).toMatchObject({ parts: 2, lessons: 2, projects: 1, exercises: 3, required: 2, hours: 2 });
  });

  it('orders exercise kinds from the most frequent', () => {
    expect([...routeMetrics(PARTS).kinds.entries()]).toEqual([
      ['resolver', 2],
      ['predecir', 1],
    ]);
  });

  it('returns zeros for an empty route', () => {
    const metrics = routeMetrics([]);
    expect(metrics).toMatchObject({ parts: 0, lessons: 0, exercises: 0, hours: 0 });
    expect(metrics.kinds.size).toBe(0);
  });
});

describe('route time', () => {
  it('adds the minutes of every lesson', () => {
    expect(totalMinutes([lesson(15, []), lesson(20, [])])).toBe(35);
  });

  it('never reports less than one hour for a non empty stretch', () => {
    expect(hoursOf([lesson(10, [])])).toBe(1);
    expect(hoursOf([lesson(100, []), lesson(50, [])])).toBe(3);
  });
});
