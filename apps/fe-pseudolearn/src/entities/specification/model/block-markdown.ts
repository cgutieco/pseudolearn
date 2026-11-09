import type { MarkdownContext } from './markdown-labels';
import { codeFence, inlineCode, runsMarkdown } from './runs-markdown';
import {
  PSEUDOCODE,
  anatomyMarkdown,
  figureMarkdown,
  programMarkdown,
  quote,
  seeAlsoMarkdown,
  tableMarkdown,
  traceMarkdown,
} from './composite-markdown';
import type { FormPiece, Runs, SpecificationBlock } from './specification';

export type { MarkdownContext } from './markdown-labels';

type BlockOfType<Kind extends SpecificationBlock['type']> = Extract<SpecificationBlock, { type: Kind }>;

type BlockRenderers = {
  readonly [Kind in SpecificationBlock['type']]: (
    block: BlockOfType<Kind>,
    context: MarkdownContext,
  ) => string;
};

const runsOf = (value: Runs, context: MarkdownContext) => runsMarkdown(value, context.sectionHref);

const RENDERERS: BlockRenderers = {
  heading: (block, context) => `## ${block.number} ${runsOf(block.runs, context)}`,
  paragraph: (block, context) => runsOf(block.runs, context),
  list: (block, context) =>
    block.entries
      .map((entry, index) => `${listMarker(block.ordered, index)} ${runsOf(entry, context)}`)
      .join('\n'),
  table: (block, context) =>
    tableMarkdown(
      block.header.map((cell) => runsOf(cell, context)),
      block.rows.map((row) => row.map((cell) => runsOf(cell, context))),
    ),
  form: (block) => codeFence(PSEUDOCODE, block.lines.map(formLine)),
  anatomy: (block, context) => anatomyMarkdown(block.parts, (value) => runsOf(value, context)),
  program: (block, context) => programMarkdown(block, context.labels),
  figure: figureMarkdown,
  callout: (block, context) =>
    quote(`**${context.labels.callouts[block.kind]}**\n\n${blocksMarkdown(block.blocks, context)}`),
  summary: (block, context) =>
    [`**${context.labels.summary}**`, ...block.points.map((point) => `- ${runsOf(point, context)}`)].join(
      '\n',
    ),
  see_also: (block, context) => seeAlsoMarkdown(block.links, context),
  diagnostic: (block) => `- ${inlineCode(block.code)} (${block.severity}): ${block.message}`,
  intermediate: (block, context) => `**${context.labels.intermediate}**\n\n${codeFence('text', block.lines)}`,
  trace: (block, context) => traceMarkdown(block.events, context.labels),
};

function blockMarkdown<Kind extends SpecificationBlock['type']>(
  block: BlockOfType<Kind>,
  context: MarkdownContext,
): string {
  const render = RENDERERS[block.type as Kind] as (
    block: BlockOfType<Kind>,
    context: MarkdownContext,
  ) => string;
  return render(block, context);
}

export function blocksMarkdown(blocks: readonly SpecificationBlock[], context: MarkdownContext): string {
  return blocks.map((block) => blockMarkdown(block, context)).join('\n\n');
}

function listMarker(ordered: boolean, index: number): string {
  return ordered ? `${index + 1}.` : '-';
}

const FORM_PIECE_TEXT: {
  readonly [Kind in FormPiece['type']]: (piece: Extract<FormPiece, { type: Kind }>) => string;
} = {
  token: (piece) => piece.token[0],
  slot: (piece) => `«${piece.text}»`,
  optional: (piece) => piece.text,
};

function formLine(pieces: readonly FormPiece[]): string {
  return pieces.map((piece) => (FORM_PIECE_TEXT[piece.type] as (piece: FormPiece) => string)(piece)).join('');
}
