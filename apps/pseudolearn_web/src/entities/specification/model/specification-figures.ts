import type { SpecificationEdition } from './specification';

export interface SpecificationFigures {
  readonly parts: number;
  readonly sections: number;
  readonly programs: number;
  readonly figures: number;
}

interface BlockCount {
  programs: number;
  figures: number;
}

function countBlocks(value: unknown, count: BlockCount): void {
  if (Array.isArray(value)) {
    for (const item of value) countBlocks(item, count);
    return;
  }
  if (typeof value !== 'object' || value === null) return;
  const block = value as { type?: unknown; executed?: unknown };
  if (block.type === 'program' && block.executed === true) count.programs += 1;
  if (block.type === 'figure') count.figures += 1;
  for (const child of Object.values(value)) countBlocks(child, count);
}

export function specificationFigures(edition: SpecificationEdition): SpecificationFigures {
  const count: BlockCount = { programs: 0, figures: 0 };
  for (const section of edition.sections.values()) countBlocks(section.blocks, count);
  return { parts: edition.contents.length, sections: edition.sections.size, ...count };
}
