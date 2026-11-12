import type { RouteBlock, RouteRuns } from './route';

export function phaseBlocks(blocks: readonly RouteBlock[], phase: number): readonly RouteBlock[] {
  const start = blocks.findIndex((block) => block.type === 'cycle' && block.phases.includes(phase));
  if (start < 0) return [];
  const rest = blocks.slice(start + 1);
  const end = rest.findIndex((block) => block.type === 'cycle');
  return end < 0 ? rest : rest.slice(0, end);
}

export function phaseList(blocks: readonly RouteBlock[], phase: number): readonly RouteRuns[] {
  const list = phaseBlocks(blocks, phase).find((block) => block.type === 'list');
  return list?.type === 'list' ? list.entries : [];
}

export function paradigmQuestion(blocks: readonly RouteBlock[]): RouteRuns {
  const paradigm = blocks.find((block) => block.type === 'paradigm');
  return paradigm?.type === 'paradigm' ? paradigm.question : [];
}

export function summaryPoints(blocks: readonly RouteBlock[]): readonly RouteRuns[] {
  const summary = blocks.find((block) => block.type === 'summary');
  return summary?.type === 'summary' ? summary.points : [];
}

export function asSentence(text: string): string {
  const index = text.search(/\p{L}/u);
  if (index < 0) return text;
  return `${text.slice(0, index)}${text.charAt(index).toLocaleUpperCase()}${text.slice(index + 1)}`;
}
