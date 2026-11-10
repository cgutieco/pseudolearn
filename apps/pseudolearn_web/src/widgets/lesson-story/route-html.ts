import { sectionPath } from '@entities/specification/model/section-address';
import { specificationRuns } from '@entities/learning-route/model/route-runs';
import type { RouteRuns } from '@entities/learning-route/model/route';
import type { Locale } from '@shared/i18n/locales';
import { localizePath } from '@shared/i18n/routes';
import { runsHtml } from '@widgets/specification-reader/runs-html';

export function routeRunsHtml(runs: RouteRuns, locale: Locale): string {
  return runsHtml(specificationRuns(runs), (sectionId) => localizePath(sectionPath(sectionId), locale));
}
