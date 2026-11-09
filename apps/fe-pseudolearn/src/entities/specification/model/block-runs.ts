import type { Runs, SpecificationBlock, SpecificationSection } from './specification';

export function blockRuns(block: SpecificationBlock): readonly Runs[] {
  switch (block.type) {
    case 'heading':
    case 'paragraph':
      return [block.runs];
    case 'list':
      return block.entries;
    case 'table':
      return [...block.header, ...block.rows.flat()];
    case 'anatomy':
      return block.parts.map((part) => part.label);
    case 'figure':
      return [
        block.caption,
        ...block.steps.map((step) => step.runs),
        ...block.panels.map((panel) => panel.runs),
      ];
    case 'summary':
      return block.points;
    default:
      return [];
  }
}

export function nestedBlocks(blocks: readonly SpecificationBlock[]): readonly SpecificationBlock[] {
  return blocks.flatMap((block) =>
    block.type === 'callout' ? [block, ...nestedBlocks(block.blocks)] : [block],
  );
}

export function linkedSections(section: SpecificationSection): readonly string[] {
  const blocks = nestedBlocks(section.blocks);
  const fromRuns = [section.title, section.phrase, ...blocks.flatMap(blockRuns)]
    .flat()
    .flatMap((run) => (run.type === 'link' ? [run.section] : []));
  const fromSeeAlso = blocks.flatMap((block) =>
    block.type === 'see_also' ? block.links.map((link) => link.section) : [],
  );
  return [...new Set([...fromRuns, ...fromSeeAlso])];
}
