import type { MarkdownLabels } from '../model/markdown-labels';
import type { ContentsPart, SpecificationBlock, SpecificationSection } from '../model/specification';

export function sectionFixture(id: string, blocks: readonly SpecificationBlock[] = []): SpecificationSection {
  return {
    id,
    number: '1.1',
    kind: 'concepto',
    title: [{ type: 'text', text: `Title ${id}` }],
    phrase: [{ type: 'text', text: `Phrase ${id}` }],
    blocks,
  };
}

export function contentsFixture(...ids: readonly string[]): ContentsPart[] {
  return [
    {
      id: 'parte-1',
      number: '1',
      title: 'Part',
      summary: 'Summary',
      sections: ids.map((id) => {
        const section = sectionFixture(id);
        return {
          id,
          number: section.number,
          kind: section.kind,
          title: section.title,
          phrase: section.phrase,
        };
      }),
    },
  ];
}

export const LABELS_FIXTURE: MarkdownLabels = {
  callouts: {
    phrase: 'Phrase',
    limit: 'Limit',
    inside: 'Inside',
    analogy: 'Analogy',
    note: 'Note',
    parts: 'Parts',
    errors: 'Errors',
  },
  terminations: { completed: 'Completed', failed: 'Failed', awaiting_input: 'Waiting', '': 'Not run' },
  figure: 'Figure',
  step: 'Step',
  program: 'Program',
  input: 'Input',
  output: 'Output',
  diagnostics: 'Diagnostics',
  summary: 'Summary',
  seeAlso: 'See also',
  intermediate: 'IR',
  trace: 'Trace',
  traceLine: 'Line',
  traceEvent: 'Event',
  webPage: 'Web page',
};
