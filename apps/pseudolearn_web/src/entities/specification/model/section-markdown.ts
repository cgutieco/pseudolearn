import { blocksMarkdown, type MarkdownContext } from './block-markdown';
import { runsMarkdown } from './runs-markdown';
import { runsText } from './plain-text';
import type { ContentsPart, SpecificationSection } from './specification';

export interface DocumentContext extends MarkdownContext {
  readonly pageUrl: string;
}

export interface ContentsHeading {
  readonly title: string;
  readonly lead: string;
}

export function sectionMarkdown(section: SpecificationSection, context: DocumentContext): string {
  return (
    [
      `# ${section.number} ${runsText(section.title)}`,
      `> ${runsMarkdown(section.phrase, context.sectionHref)}`,
      `${context.labels.webPage}: ${context.pageUrl}`,
      blocksMarkdown(section.blocks, context),
    ].join('\n\n') + '\n'
  );
}

export function contentsMarkdown(
  parts: readonly ContentsPart[],
  heading: ContentsHeading,
  context: DocumentContext,
): string {
  const partsText = parts.map((part) =>
    [
      `## ${part.number}. ${part.title}`,
      part.summary,
      part.sections
        .map(
          (entry) =>
            `- [${entry.number} ${runsText(entry.title)}](${context.sectionHref(entry.id)}): ${runsText(entry.phrase)}`,
        )
        .join('\n'),
    ].join('\n\n'),
  );
  return (
    [
      `# ${heading.title}`,
      `> ${heading.lead}`,
      `${context.labels.webPage}: ${context.pageUrl}`,
      ...partsText,
    ].join('\n\n') + '\n'
  );
}
