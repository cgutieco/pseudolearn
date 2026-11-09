export type HighlightCategory =
  | 'keywordStructured'
  | 'keywordProcedural'
  | 'keywordOop'
  | 'identifier'
  | 'type'
  | 'literalNumber'
  | 'literalString'
  | 'literalBoolean'
  | 'operator'
  | 'punctuation'
  | 'comment';

export type CodeToken = readonly [string] | readonly [string, HighlightCategory];

export type InlineRun =
  | { readonly type: 'text' | 'strong' | 'emphasis' | 'slot'; readonly text: string }
  | { readonly type: 'code'; readonly tokens: readonly CodeToken[] }
  | { readonly type: 'link'; readonly section: string; readonly text: string }
  | { readonly type: 'term'; readonly term: string; readonly text: string };

export type Runs = readonly InlineRun[];

export type FormPiece =
  | { readonly type: 'token'; readonly token: CodeToken }
  | { readonly type: 'slot'; readonly text: string }
  | { readonly type: 'optional'; readonly text: string };

export type CalloutKind = 'phrase' | 'limit' | 'inside' | 'analogy' | 'note' | 'parts' | 'errors';

export type SectionKind = 'concepto' | 'construccion' | 'tipo' | 'motor' | 'apendice';

export type ProgramTermination = 'completed' | 'failed' | 'awaiting_input' | '';

export interface ProgramDiagnostic {
  readonly code: string;
  readonly severity: string;
  readonly line: number;
  readonly column: number;
  readonly message: string;
}

export interface ProgramBlock {
  readonly type: 'program';
  readonly id: string;
  readonly title: string;
  readonly source: string;
  readonly lines: readonly (readonly CodeToken[])[];
  readonly executed: boolean;
  readonly inputs?: readonly string[];
  readonly output: string;
  readonly termination: ProgramTermination;
  readonly diagnostics: readonly ProgramDiagnostic[];
}

export interface FigureLayer {
  readonly from_step: number;
  readonly until_step?: number;
  readonly svg: string;
}

export interface FigurePanel {
  readonly zone: string;
  readonly from_step: number;
  readonly runs: Runs;
}

export interface FigureBlock {
  readonly type: 'figure';
  readonly id: string;
  readonly number: string;
  readonly alt: string;
  readonly description: string;
  readonly caption: Runs;
  readonly svg: string;
  readonly layers: readonly FigureLayer[];
  readonly steps: readonly { readonly runs: Runs }[];
  readonly panels: readonly FigurePanel[];
}

export interface SeeAlsoLink {
  readonly section: string;
  readonly number: string;
  readonly title: string;
}

export interface TraceEvent {
  readonly line: number;
  readonly class: string;
  readonly detail: string;
}

export type SpecificationBlock =
  | { readonly type: 'heading'; readonly id: string; readonly number: string; readonly runs: Runs }
  | { readonly type: 'paragraph'; readonly runs: Runs }
  | { readonly type: 'list'; readonly ordered: boolean; readonly entries: readonly Runs[] }
  | { readonly type: 'table'; readonly header: readonly Runs[]; readonly rows: readonly (readonly Runs[])[] }
  | { readonly type: 'form'; readonly lines: readonly (readonly FormPiece[])[] }
  | {
      readonly type: 'anatomy';
      readonly parts: readonly { readonly tokens: readonly CodeToken[]; readonly label: Runs }[];
    }
  | ProgramBlock
  | FigureBlock
  | {
      readonly type: 'callout';
      readonly kind: CalloutKind;
      readonly collapsible: boolean;
      readonly blocks: readonly SpecificationBlock[];
    }
  | { readonly type: 'summary'; readonly points: readonly Runs[] }
  | { readonly type: 'see_also'; readonly links: readonly SeeAlsoLink[] }
  | {
      readonly type: 'diagnostic';
      readonly code: string;
      readonly severity: string;
      readonly message: string;
    }
  | { readonly type: 'intermediate'; readonly program: string; readonly lines: readonly string[] }
  | { readonly type: 'trace'; readonly program: string; readonly events: readonly TraceEvent[] };

export interface SpecificationSection {
  readonly id: string;
  readonly number: string;
  readonly kind: SectionKind;
  readonly title: Runs;
  readonly phrase: Runs;
  readonly blocks: readonly SpecificationBlock[];
}

export interface ContentsSection {
  readonly id: string;
  readonly number: string;
  readonly kind: SectionKind;
  readonly title: Runs;
  readonly phrase: Runs;
}

export interface ContentsPart {
  readonly id: string;
  readonly number: string;
  readonly title: string;
  readonly summary: string;
  readonly sections: readonly ContentsSection[];
}

export interface SpecificationEdition {
  readonly contents: readonly ContentsPart[];
  readonly sections: ReadonlyMap<string, SpecificationSection>;
}
