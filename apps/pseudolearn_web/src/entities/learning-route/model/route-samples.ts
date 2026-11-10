import type { Locale } from '@shared/i18n/locales';
import type {
  ExerciseKind,
  RouteBlock,
  RouteExercise,
  RouteExerciseEntry,
  RouteLesson,
  RouteLessonEntry,
  RoutePart,
} from './route';

const LESSON_FILES = import.meta.glob<unknown>('../generated/*/lessons/*.json', { import: 'default' });
const EXERCISE_FILES = import.meta.glob<unknown>('../generated/*/exercises/*.json', { import: 'default' });

async function loadFile<Shape>(files: Record<string, () => Promise<unknown>>, path: string): Promise<Shape> {
  const loader = files[path];
  if (loader === undefined) throw new Error(`The learning route has no file ${path}`);
  return (await loader()) as Shape;
}

export function loadLesson(locale: Locale, id: string): Promise<RouteLesson> {
  return loadFile<RouteLesson>(LESSON_FILES, `../generated/${locale}/lessons/${id}.json`);
}

export function loadExercise(locale: Locale, id: string): Promise<RouteExercise> {
  return loadFile<RouteExercise>(EXERCISE_FILES, `../generated/${locale}/exercises/${id}.json`);
}

export function firstLesson(parts: readonly RoutePart[]): RouteLessonEntry {
  const lesson = parts.flatMap((part) => part.lessons)[0];
  if (lesson === undefined) throw new Error('The learning route has no lessons');
  return lesson;
}

export function firstExerciseOfKind(
  parts: readonly RoutePart[],
  kind: ExerciseKind,
): RouteExerciseEntry | undefined {
  return parts
    .flatMap((part) => part.lessons)
    .flatMap((lesson) => lesson.exercises)
    .find((exercise) => exercise.kind === kind);
}

export function problemBlocks(blocks: readonly RouteBlock[]): readonly RouteBlock[] {
  const problem = blocks.find((block) => block.type === 'problem');
  return problem?.type === 'problem' ? problem.blocks : [];
}

export function attemptAnswer(blocks: readonly RouteBlock[]): readonly RouteBlock[] {
  const attempt = blocks.find((block) => block.type === 'attempt');
  return attempt?.type === 'attempt' ? attempt.answer : [];
}

export function paragraphRuns(blocks: readonly RouteBlock[]) {
  return blocks.flatMap((block) => (block.type === 'paragraph' ? [block.runs] : []));
}
