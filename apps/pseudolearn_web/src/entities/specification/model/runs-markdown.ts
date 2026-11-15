import type { SectionHref } from './markdown-labels';
import { tokensText } from './plain-text';
import type { CodeToken, InlineRun, Runs } from './specification';

const BACKTICK = '`';

export function inlineCode(text: string): string {
  const fence = text.includes(BACKTICK) ? '``' : BACKTICK;
  const padding = text.startsWith(BACKTICK) || text.endsWith(BACKTICK) ? ' ' : '';
  return `${fence}${padding}${text}${padding}${fence}`;
}

export function tokensMarkdown(tokens: readonly CodeToken[]): string {
  return inlineCode(tokensText(tokens));
}

function runMarkdown(run: InlineRun, sectionHref: SectionHref): string {
  switch (run.type) {
    case 'strong':
      return `**${run.text}**`;
    case 'emphasis':
      return `*${run.text}*`;
    case 'code':
      return tokensMarkdown(run.tokens);
    case 'slot':
      return `«${run.text}»`;
    case 'link':
      return `[${run.text}](${sectionHref(run.section)})`;
    default:
      return run.text;
  }
}

export function runsMarkdown(runs: Runs, sectionHref: SectionHref): string {
  return runs.map((run) => runMarkdown(run, sectionHref)).join('');
}

export function codeFence(language: string, lines: readonly string[]): string {
  const body = lines.join('\n').replace(/\n+$/, '');
  const fence = body.includes('```') ? '~~~~' : '```';
  return `${fence}${language}\n${body}\n${fence}`;
}

export function tableCell(text: string): string {
  return text.replaceAll('|', '\\|').replaceAll('\n', ' ');
}
