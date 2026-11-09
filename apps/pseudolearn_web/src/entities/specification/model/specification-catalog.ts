import type { Locale } from '@shared/i18n/locales';
import { LOCALES } from '@shared/i18n/locales';
import { readEdition } from './read-edition';
import type { ContentsSection, SpecificationEdition, SpecificationSection } from './specification';

const CONTENTS_FILES = import.meta.glob<unknown>('../generated/*/toc.json', {
  eager: true,
  import: 'default',
});
const SECTION_FILES = import.meta.glob<unknown>('../generated/*/sections/*.json', {
  eager: true,
  import: 'default',
});

function loadEdition(locale: Locale): SpecificationEdition {
  const prefix = `../generated/${locale}/`;
  const sectionFiles = Object.fromEntries(
    Object.entries(SECTION_FILES).filter(([path]) => path.startsWith(`${prefix}sections/`)),
  );
  const reading = readEdition(CONTENTS_FILES[`${prefix}toc.json`], sectionFiles);
  if (reading.problems.length > 0) {
    const details = reading.problems.map((problem) => `${problem.path} (${problem.rule})`).join(', ');
    throw new Error(`The ${locale} specification cannot be published: ${details}`);
  }
  return reading.edition;
}

const EDITIONS: ReadonlyMap<Locale, SpecificationEdition> = new Map(
  LOCALES.map((locale) => [locale, loadEdition(locale)]),
);

export function specificationEdition(locale: Locale): SpecificationEdition {
  const edition = EDITIONS.get(locale);
  if (edition === undefined) throw new Error(`Unknown specification locale: ${locale}`);
  return edition;
}

export function orderedSections(locale: Locale): readonly ContentsSection[] {
  return specificationEdition(locale).contents.flatMap((part) => part.sections);
}

export function findSection(locale: Locale, id: string): SpecificationSection | undefined {
  return specificationEdition(locale).sections.get(id);
}
