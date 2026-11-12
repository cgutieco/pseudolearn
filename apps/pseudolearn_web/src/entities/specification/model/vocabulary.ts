import { codeTone, type CodeTone } from './code-tone';
import type { HighlightCategory, Runs, SpecificationSection } from './specification';

export interface VocabularyPair {
  readonly spanish: string;
  readonly english: string;
  readonly tone: CodeTone;
}

export const VOCABULARY_SECTION = 'apendice.palabras';

const KEYWORD_CATEGORIES: readonly HighlightCategory[] = [
  'keywordStructured',
  'keywordProcedural',
  'keywordOop',
];

interface Keyword {
  readonly text: string;
  readonly category: HighlightCategory;
}

function keywordOf(cell: Runs | undefined): Keyword | undefined {
  const [run] = cell ?? [];
  if (cell?.length !== 1 || run?.type !== 'code' || run.tokens.length !== 1) return undefined;
  const [text, category] = run.tokens[0] ?? [''];
  return category !== undefined && KEYWORD_CATEGORIES.includes(category) ? { text, category } : undefined;
}

export function vocabularyPairs(section: SpecificationSection | undefined): readonly VocabularyPair[] {
  const table = section?.blocks.find((block) => block.type === 'table');
  if (table?.type !== 'table') return [];
  return table.rows.flatMap((row) => {
    const spanish = keywordOf(row[0]);
    const english = keywordOf(row[1]);
    if (spanish === undefined || english === undefined) return [];
    return [{ spanish: spanish.text, english: english.text, tone: codeTone(spanish.category) }];
  });
}

export function pickPairs(
  pairs: readonly VocabularyPair[],
  spanishWords: readonly string[],
): readonly VocabularyPair[] {
  return spanishWords.flatMap((word) => pairs.filter((pair) => pair.spanish === word));
}
