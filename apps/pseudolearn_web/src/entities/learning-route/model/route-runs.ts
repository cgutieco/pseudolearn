import type { InlineRun, Runs } from '@entities/specification/model/specification';
import type { RouteRun, RouteRuns } from './route';

function toSpecificationRun(run: RouteRun): InlineRun {
  switch (run.type) {
    case 'definition':
      return { type: 'term', term: run.term, text: run.text };
    case 'spec_link':
      return { type: 'link', section: run.section, text: run.text };
    default:
      return run;
  }
}

export function specificationRuns(runs: RouteRuns): Runs {
  return runs.map(toSpecificationRun);
}

export function plainRouteText(runs: RouteRuns): string {
  return runs.map((run) => ('text' in run ? run.text : run.tokens.map(([text]) => text).join(''))).join('');
}
