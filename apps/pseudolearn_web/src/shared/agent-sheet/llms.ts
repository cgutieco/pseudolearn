import spanishSheet from './generated/language-sheet.es.md?raw';
import englishSheet from './generated/language-sheet.en.md?raw';

const indexLines = [
  '# PseudoLearn',
  '',
  '> PseudoLearn is a general-purpose teaching programming language with Spanish and English syntax profiles, and a learning app for macOS, Windows, iPhone and iPad. It looks like PSeInt but follows its own specification: zero-based arrays, mandatory semicolons, typed declarations, modules, objects, higher-order functions and concurrent tasks.',
  '',
  '## Language',
  '',
  '- [Full language sheet for agents](/llms-full.txt): vocabulary, grammar, library, differences from PSeInt and executed examples, in English and Spanish.',
  '- [The language](/en/language): paradigms, syntax profiles and environments (app now; VS Code extension and command line coming soon).',
  '',
  '## Learning',
  '',
  '- [Learning path](/en/learn): parts, lessons, exercise kinds and the five-phase problem-solving cycle.',
  '- [Nodo](/en/nodo): the optional AI learning assistant inside the app, its rules, plans and privacy.',
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
