import type { CodeToken, ProgramBlock } from '@entities/specification/model/specification';

export type RouteRun =
  | { readonly type: 'text' | 'strong' | 'emphasis'; readonly text: string }
  | { readonly type: 'code'; readonly tokens: readonly CodeToken[] }
  | { readonly type: 'definition'; readonly term: string; readonly text: string }
  | { readonly type: 'spec_link'; readonly section: string; readonly text: string };

export type RouteRuns = readonly RouteRun[];

export const EXERCISE_KINDS = [
  'predecir',
  'rastrear',
  'ordenar',
  'encontrar-error',
  'romperlo',
  'disenar-pruebas',
  'modificar',
  'resolver',
  'comparar',
  'clasificar',
  'explicar',
] as const;

export type ExerciseKind = (typeof EXERCISE_KINDS)[number];

export type ExerciseLevel = 'semilla' | 'brote' | 'arbol';

export type LessonKind = 'apertura' | 'leccion' | 'proyecto';

export interface RouteExerciseEntry {
  readonly id: string;
  readonly kind: ExerciseKind;
  readonly level: ExerciseLevel;
  readonly required: boolean;
  readonly title: RouteRuns;
}

export interface RouteLessonEntry {
  readonly id: string;
  readonly number: string;
  readonly kind: LessonKind;
  readonly title: RouteRuns;
  readonly brief_problem: string;
  readonly minutes: number;
  readonly exercises: readonly RouteExerciseEntry[];
}

export interface RoutePart {
  readonly id: string;
  readonly number: string;
  readonly title: string;
  readonly motto: string;
  readonly summary: string;
  readonly lessons: readonly RouteLessonEntry[];
}

export interface RouteParagraph {
  readonly type: 'paragraph';
  readonly runs: RouteRuns;
}

export type RouteBlock =
  | RouteParagraph
  | { readonly type: 'phrase'; readonly runs: RouteRuns }
  | { readonly type: 'cycle'; readonly phases: readonly number[] }
  | { readonly type: 'list'; readonly ordered: boolean; readonly entries: readonly RouteRuns[] }
  | { readonly type: 'summary'; readonly points: readonly RouteRuns[] }
  | {
      readonly type: 'paradigm';
      readonly question: RouteRuns;
      readonly metaphor: RouteRuns;
    }
  | { readonly type: 'problem'; readonly blocks: readonly RouteBlock[] }
  | {
      readonly type: 'attempt';
      readonly prompt: readonly RouteBlock[];
      readonly answer: readonly RouteBlock[];
    }
  | ProgramBlock
  | { readonly type: 'other' };

export interface RouteLesson {
  readonly id: string;
  readonly number: string;
  readonly title: RouteRuns;
  readonly brief_problem: string;
  readonly minutes: number;
  readonly blocks: readonly RouteBlock[];
}

export interface RouteExercise {
  readonly id: string;
  readonly lesson: string;
  readonly kind: ExerciseKind;
  readonly level: ExerciseLevel;
  readonly title: RouteRuns;
  readonly statement: readonly RouteBlock[];
  readonly hints: readonly RouteRuns[];
  readonly explanation: readonly RouteBlock[];
  readonly program?: ProgramBlock;
}
