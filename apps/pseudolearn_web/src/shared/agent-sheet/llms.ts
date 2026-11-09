import spanishSheet from './generated/language-sheet.es.md?raw';
import englishSheet from './generated/language-sheet.en.md?raw';

const indexLines = [
  '# PseudoLearn',
  '',
  '> PseudoLearn is a pseudocode language and learning app with Spanish and English syntax profiles. It looks like PSeInt but follows its own specification: zero-based arrays, mandatory semicolons and typed declarations.',
  '',
  '## Language',
  '',
  '- [Full language sheet for agents](/llms-full.txt): vocabulary, grammar, library, differences from PSeInt and executed examples, in English and Spanish.',
];

const SPECIFICATION_HEADING = ['', '## Illustrated specification', ''];

export function llmsIndex(specificationLinks: readonly string[] = []): string {
  const specification =
    specificationLinks.length === 0 ? [] : [...SPECIFICATION_HEADING, ...specificationLinks];
  return `${[...indexLines, ...specification].join('\n')}\n`;
}

export function llmsFull(): string {
  return `${englishSheet}\n---\n\n${spanishSheet}`;
}

export const plainText = { 'content-type': 'text/plain; charset=utf-8' };
