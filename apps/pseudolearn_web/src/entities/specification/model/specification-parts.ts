import type { Locale } from '@shared/i18n/locales';
import { LOCALES } from '@shared/i18n/locales';

export interface SpecificationPart {
  readonly id: string;
  readonly number: string;
  readonly title: string;
}

const CONTENTS_FILES = import.meta.glob<unknown>('../generated/*/toc.json', {
  eager: true,
  import: 'default',
});

export const SPECIFICATION_SUBJECT_PREFIX = 'spec:';

function isPart(value: unknown): value is SpecificationPart {
  if (typeof value !== 'object' || value === null) return false;
  const candidate = value as Partial<SpecificationPart>;
  return typeof candidate.id === 'string' && typeof candidate.title === 'string';
}

export function specificationParts(locale: Locale): readonly SpecificationPart[] {
  const contents = CONTENTS_FILES[`../generated/${locale}/toc.json`];
  return Array.isArray(contents) ? contents.filter(isPart) : [];
}

export function specificationSubject(part: SpecificationPart): string {
  return `${SPECIFICATION_SUBJECT_PREFIX}${part.id}`;
}

export function isSpecificationSubject(candidate: string): boolean {
  return LOCALES.some((locale) =>
    specificationParts(locale).some((part) => specificationSubject(part) === candidate),
  );
}
