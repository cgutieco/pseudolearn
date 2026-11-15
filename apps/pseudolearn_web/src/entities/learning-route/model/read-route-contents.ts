import { EXERCISE_KINDS, type RouteLessonEntry, type RoutePart } from './route';

export type RouteContentsRule =
  'ROUTE-CONTENTS-EMPTY' | 'ROUTE-PART-SHAPE' | 'ROUTE-LESSON-SHAPE' | 'ROUTE-EXERCISE-KIND';

export interface RouteContentsProblem {
  readonly rule: RouteContentsRule;
  readonly path: string;
}

export interface RouteContentsReading {
  readonly parts: readonly RoutePart[];
  readonly problems: readonly RouteContentsProblem[];
}

export function readRouteContents(contents: unknown): RouteContentsReading {
  const candidates: readonly unknown[] = Array.isArray(contents) ? contents : [];
  if (candidates.length === 0) {
    return { parts: [], problems: [{ rule: 'ROUTE-CONTENTS-EMPTY', path: 'toc.json' }] };
  }
  const problems: RouteContentsProblem[] = [];
  const parts = candidates.filter((candidate, index): candidate is RoutePart => {
    if (!isPart(candidate)) {
      problems.push({ rule: 'ROUTE-PART-SHAPE', path: `toc.json[${index}]` });
      return false;
    }
    problems.push(...lessonProblems(candidate), ...kindProblems(candidate));
    return true;
  });
  return { parts, problems };
}

function isPart(value: unknown): value is RoutePart {
  if (typeof value !== 'object' || value === null) return false;
  const candidate = value as Partial<RoutePart>;
  return (
    typeof candidate.id === 'string' &&
    typeof candidate.number === 'string' &&
    typeof candidate.title === 'string' &&
    Array.isArray(candidate.lessons)
  );
}

function lessonProblems(part: RoutePart): RouteContentsProblem[] {
  return part.lessons
    .filter((lesson) => !isLesson(lesson))
    .map((lesson) => ({ rule: 'ROUTE-LESSON-SHAPE' as const, path: `${part.id} -> ${describe(lesson)}` }));
}

function kindProblems(part: RoutePart): RouteContentsProblem[] {
  const known: readonly string[] = EXERCISE_KINDS;
  return part.lessons
    .filter(isLesson)
    .flatMap((lesson) => lesson.exercises)
    .filter((exercise) => !known.includes(exercise.kind))
    .map((exercise) => ({ rule: 'ROUTE-EXERCISE-KIND' as const, path: `${part.id} -> ${exercise.id}` }));
}

function isLesson(value: unknown): value is RouteLessonEntry {
  if (typeof value !== 'object' || value === null) return false;
  const candidate = value as Partial<RouteLessonEntry>;
  return (
    typeof candidate.id === 'string' &&
    typeof candidate.minutes === 'number' &&
    Array.isArray(candidate.title) &&
    Array.isArray(candidate.exercises)
  );
}

function describe(value: unknown): string {
  const id = (value as { id?: unknown } | null)?.id;
  return typeof id === 'string' ? id : 'lesson';
}
