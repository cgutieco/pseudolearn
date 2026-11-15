import type { ExerciseKind, ExerciseLevel, RouteLessonEntry, RoutePart } from './route';

export interface RouteMetrics {
  readonly parts: number;
  readonly lessons: number;
  readonly projects: number;
  readonly exercises: number;
  readonly required: number;
  readonly hours: number;
  readonly kinds: ReadonlyMap<ExerciseKind, number>;
  readonly levels: ReadonlyMap<ExerciseLevel, number>;
}

const MINUTES_PER_HOUR = 60;

export function routeMetrics(parts: readonly RoutePart[]): RouteMetrics {
  const lessons = parts.flatMap((part) => part.lessons);
  const exercises = lessons.flatMap((lesson) => lesson.exercises);
  return {
    parts: parts.length,
    lessons: lessons.length,
    projects: lessons.filter((lesson) => lesson.kind === 'proyecto').length,
    exercises: exercises.length,
    required: exercises.filter((exercise) => exercise.required).length,
    hours: Math.round(totalMinutes(lessons) / MINUTES_PER_HOUR),
    kinds: countBy(exercises.map((exercise) => exercise.kind)),
    levels: countBy(exercises.map((exercise) => exercise.level)),
  };
}

export function totalMinutes(lessons: readonly RouteLessonEntry[]): number {
  return lessons.reduce((sum, lesson) => sum + lesson.minutes, 0);
}

export function hoursOf(lessons: readonly RouteLessonEntry[]): number {
  return Math.max(1, Math.round(totalMinutes(lessons) / MINUTES_PER_HOUR));
}

function countBy<Key extends string>(keys: readonly Key[]): ReadonlyMap<Key, number> {
  const counts = new Map<Key, number>();
  for (const key of keys) counts.set(key, (counts.get(key) ?? 0) + 1);
  return new Map([...counts.entries()].sort(([, left], [, right]) => right - left));
}
