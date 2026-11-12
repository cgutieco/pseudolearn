import type { Locale } from '@shared/i18n/locales';
import { LOCALES } from '@shared/i18n/locales';
import { readRouteContents } from './read-route-contents';
import type { RouteLessonEntry, RoutePart } from './route';

const CONTENTS_FILES = import.meta.glob<unknown>('../generated/*/toc.json', {
  eager: true,
  import: 'default',
});

function loadParts(locale: Locale): readonly RoutePart[] {
  const reading = readRouteContents(CONTENTS_FILES[`../generated/${locale}/toc.json`]);
  if (reading.problems.length > 0) {
    const details = reading.problems.map((problem) => `${problem.path} (${problem.rule})`).join(', ');
    throw new Error(`The ${locale} learning route cannot be published: ${details}`);
  }
  return reading.parts;
}

const PARTS: ReadonlyMap<Locale, readonly RoutePart[]> = new Map(
  LOCALES.map((locale) => [locale, loadParts(locale)]),
);

export function routeParts(locale: Locale): readonly RoutePart[] {
  const parts = PARTS.get(locale);
  if (parts === undefined) throw new Error(`Unknown learning route locale: ${locale}`);
  return parts;
}

export function routeLessons(locale: Locale): readonly RouteLessonEntry[] {
  return routeParts(locale).flatMap((part) => part.lessons);
}

export function isRouteLesson(candidate: string): boolean {
  return LOCALES.some((locale) => routeLessons(locale).some((lesson) => lesson.id === candidate));
}
