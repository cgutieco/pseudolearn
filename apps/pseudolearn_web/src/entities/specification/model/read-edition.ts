import { linkedSections } from './block-runs';
import { sectionAddress } from './section-address';
import type { ContentsPart, SpecificationEdition, SpecificationSection } from './specification';

export type EditionRule =
  | 'SPEC-CONTENTS-EMPTY'
  | 'SPEC-SECTION-SHAPE'
  | 'SPEC-SECTION-ID'
  | 'SPEC-SECTION-MISSING'
  | 'SPEC-SECTION-UNLISTED'
  | 'SPEC-LINK-BROKEN';

export interface EditionProblem {
  readonly rule: EditionRule;
  readonly path: string;
}

export interface EditionReading {
  readonly edition: SpecificationEdition;
  readonly problems: readonly EditionProblem[];
}

export function readEdition(contents: unknown, files: Readonly<Record<string, unknown>>): EditionReading {
  const parts = Array.isArray(contents) ? (contents as ContentsPart[]) : [];
  const listed = parts.flatMap((part) =>
    Array.isArray(part.sections) ? part.sections.map((entry) => entry.id) : [],
  );
  const sections = new Map<string, SpecificationSection>();
  const problems: EditionProblem[] =
    listed.length === 0 ? [{ rule: 'SPEC-CONTENTS-EMPTY', path: 'toc.json' }] : [];
  for (const [path, value] of Object.entries(files)) {
    if (isSection(value)) sections.set(value.id, value);
    else problems.push({ rule: 'SPEC-SECTION-SHAPE', path });
  }
  problems.push(...addressProblems(listed), ...coverageProblems(listed, sections), ...linkProblems(sections));
  return { edition: { contents: parts, sections }, problems };
}

function isSection(value: unknown): value is SpecificationSection {
  if (typeof value !== 'object' || value === null) return false;
  const candidate = value as Partial<SpecificationSection>;
  return (
    typeof candidate.id === 'string' &&
    typeof candidate.number === 'string' &&
    Array.isArray(candidate.blocks)
  );
}

function addressProblems(listed: readonly string[]): EditionProblem[] {
  return listed
    .filter((id) => sectionAddress(id) === null)
    .map((id) => ({ rule: 'SPEC-SECTION-ID', path: id }));
}

function coverageProblems(
  listed: readonly string[],
  sections: ReadonlyMap<string, SpecificationSection>,
): EditionProblem[] {
  const known = new Set(listed);
  return [
    ...listed
      .filter((id) => !sections.has(id))
      .map((id) => ({ rule: 'SPEC-SECTION-MISSING' as const, path: id })),
    ...[...sections.keys()]
      .filter((id) => !known.has(id))
      .map((id) => ({ rule: 'SPEC-SECTION-UNLISTED' as const, path: id })),
  ];
}

function linkProblems(sections: ReadonlyMap<string, SpecificationSection>): EditionProblem[] {
  return [...sections.values()].flatMap((section) =>
    linkedSections(section)
      .filter((target) => !sections.has(target))
      .map((target) => ({ rule: 'SPEC-LINK-BROKEN' as const, path: `${section.id} -> ${target}` })),
  );
}
