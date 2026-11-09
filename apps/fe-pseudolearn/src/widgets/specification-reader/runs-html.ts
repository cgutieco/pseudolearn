import type { InlineRun, Runs } from '@entities/specification/model/specification';
import { escapeHtml, tokensHtml } from './token-html';

export type SectionHrefFor = (sectionId: string) => string;

function runHtml(run: InlineRun, hrefFor: SectionHrefFor): string {
  switch (run.type) {
    case 'strong':
      return `<strong>${escapeHtml(run.text)}</strong>`;
    case 'emphasis':
      return `<em>${escapeHtml(run.text)}</em>`;
    case 'slot':
      return `<span class="runs__slot">«${escapeHtml(run.text)}»</span>`;
    case 'code':
      return `<code class="runs__code">${tokensHtml(run.tokens)}</code>`;
    case 'link':
      return `<a class="runs__link" href="${escapeHtml(hrefFor(run.section))}">${escapeHtml(run.text)}</a>`;
    default:
      return escapeHtml(run.text);
  }
}

export function runsHtml(runs: Runs, hrefFor: SectionHrefFor): string {
  return runs.map((run) => runHtml(run, hrefFor)).join('');
}
