import type { Locale } from '@shared/i18n/locales';

export const CHANGE_KINDS = ['feature', 'platform', 'fix'] as const;

export type ChangeKind = (typeof CHANGE_KINDS)[number];

export type LocalizedText = Readonly<Record<Locale, string>>;

export interface ReleaseChange {
  readonly id: string;
  readonly kind: ChangeKind;
  readonly title: LocalizedText;
  readonly description: LocalizedText;
}

export interface Release {
  readonly version: string;
  readonly date: string;
  readonly headline: LocalizedText;
  readonly summary: LocalizedText;
  readonly changes: readonly ReleaseChange[];
}
