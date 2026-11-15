import type { MarkdownContext, MarkdownLabels } from './markdown-labels';
import { codeFence, inlineCode, runsMarkdown, tableCell, tokensMarkdown } from './runs-markdown';
import { tokensText } from './plain-text';
import type { CodeToken, FigureBlock, ProgramBlock, Runs, SeeAlsoLink, TraceEvent } from './specification';

export const PSEUDOCODE = 'pseudolearn';

export function tableMarkdown(header: readonly string[], rows: readonly (readonly string[])[]): string {
  const line = (cells: readonly string[]) => `| ${cells.map(tableCell).join(' | ')} |`;
  return [line(header), line(header.map(() => '---')), ...rows.map(line)].join('\n');
}

export function programMarkdown(block: ProgramBlock, labels: MarkdownLabels): string {
  const parts = [`### ${labels.program}: ${block.title}`, codeFence(PSEUDOCODE, [block.source])];
  const inputs = block.inputs ?? [];
  if (inputs.length > 0) parts.push(`**${labels.input}**\n\n${codeFence('text', inputs)}`);
  if (block.output !== '') parts.push(`**${labels.output}**\n\n${codeFence('text', [block.output])}`);
  if (block.diagnostics.length > 0) {
    const entries = block.diagnostics.map(
      (diagnostic) =>
        `- ${inlineCode(diagnostic.code)} (${diagnostic.severity}, ${diagnostic.line}:${diagnostic.column}): ${diagnostic.message}`,
    );
    parts.push([`**${labels.diagnostics}**`, ...entries].join('\n'));
  }
  parts.push(`*${labels.terminations[block.termination]}*`);
  return parts.join('\n\n');
}

export function figureMarkdown(block: FigureBlock, context: MarkdownContext): string {
  const runs = (value: Runs) => runsMarkdown(value, context.sectionHref);
  const steps = block.steps.map(
    (step, index) => `${index + 1}. ${context.labels.step} ${index + 1}: ${runs(step.runs)}`,
  );
  const lines = [
    `**${context.labels.figure} ${block.number}: ${block.alt}**`,
    '',
    block.description,
    '',
    runs(block.caption),
  ];
  return [...lines, ...(steps.length > 0 ? ['', ...steps] : [])].join('\n');
}

export function traceMarkdown(events: readonly TraceEvent[], labels: MarkdownLabels): string {
  const rows = events.map((event) => `| ${event.line} | ${tableCell(event.detail)} |`);
  return [
    `**${labels.trace}**`,
    '',
    `| ${labels.traceLine} | ${labels.traceEvent} |`,
    '| --- | --- |',
    ...rows,
  ].join('\n');
}

export function anatomyMarkdown(
  parts: readonly { readonly tokens: readonly CodeToken[]; readonly label: Runs }[],
  runs: (value: Runs) => string,
): string {
  return [
    codeFence(PSEUDOCODE, [parts.map((part) => tokensText(part.tokens)).join(' ')]),
    ...parts.map((part) => `- ${tokensMarkdown(part.tokens)}: ${runs(part.label)}`),
  ].join('\n');
}

export function seeAlsoMarkdown(links: readonly SeeAlsoLink[], context: MarkdownContext): string {
  return [
    `**${context.labels.seeAlso}**`,
    ...links.map((link) => `- [${link.number} ${link.title}](${context.sectionHref(link.section)})`),
  ].join('\n');
}

export function quote(text: string): string {
  return text
    .split('\n')
    .map((line) => (line === '' ? '>' : `> ${line}`))
    .join('\n');
}
