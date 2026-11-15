import type { Locale } from '@shared/i18n/locales';
import type { RoutePart } from './route';
import { routeParts } from './route-contents';
import { loadLesson } from './route-samples';
import { asSentence, paradigmQuestion } from './route-phases';
import { plainRouteText } from './route-runs';

export interface PartStory {
  readonly part: RoutePart;
  readonly question: string;
}

export async function partStories(locale: Locale): Promise<readonly PartStory[]> {
  return Promise.all(
    routeParts(locale).map(async (part) => {
      const opener = part.lessons[0];
      const lesson = opener === undefined ? undefined : await loadLesson(locale, opener.id);
      const question = lesson === undefined ? '' : plainRouteText(paradigmQuestion(lesson.blocks));
      return { part, question: question === '' ? '' : asSentence(question) };
    }),
  );
}
