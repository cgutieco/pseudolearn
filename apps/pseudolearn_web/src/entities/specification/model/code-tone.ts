import type { HighlightCategory } from './specification';

export type CodeTone =
  'structured' | 'procedural' | 'object' | 'identifier' | 'number' | 'string' | 'plain' | 'muted';

const TONES: Readonly<Record<HighlightCategory, CodeTone>> = {
  keywordStructured: 'structured',
  keywordProcedural: 'procedural',
  keywordOop: 'object',
  type: 'structured',
  identifier: 'identifier',
  literalNumber: 'number',
  literalBoolean: 'number',
  literalString: 'string',
  operator: 'plain',
  punctuation: 'plain',
  comment: 'muted',
};

export function codeTone(category: HighlightCategory | undefined): CodeTone {
  return category === undefined ? 'plain' : TONES[category];
}
