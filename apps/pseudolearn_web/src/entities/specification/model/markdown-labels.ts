import type { TranslationKey, Translator } from '@shared/i18n/translator';
import { CALLOUT_KEYS, TERMINATION_KEYS } from './label-keys';
import type { CalloutKind, ProgramTermination } from './specification';

export interface MarkdownLabels {
  readonly callouts: Readonly<Record<CalloutKind, string>>;
  readonly terminations: Readonly<Record<ProgramTermination, string>>;
  readonly figure: string;
  readonly step: string;
  readonly program: string;
  readonly input: string;
  readonly output: string;
  readonly diagnostics: string;
  readonly summary: string;
  readonly seeAlso: string;
  readonly intermediate: string;
  readonly trace: string;
  readonly traceLine: string;
  readonly traceEvent: string;
  readonly webPage: string;
}

export type SectionHref = (id: string) => string;

export interface MarkdownContext {
  readonly labels: MarkdownLabels;
  readonly sectionHref: SectionHref;
}

function translateAll<Key extends string>(
  keys: Readonly<Record<Key, TranslationKey>>,
  translator: Translator,
): Record<Key, string> {
  const entries = (Object.keys(keys) as Key[]).map((name) => [name, translator.t(keys[name])] as const);
  return Object.fromEntries(entries) as Record<Key, string>;
}

export function markdownLabels(translator: Translator): MarkdownLabels {
  const { t } = translator;
  return {
    callouts: translateAll(CALLOUT_KEYS, translator),
    terminations: translateAll(TERMINATION_KEYS, translator),
    figure: t('specification.figure'),
    step: t('specification.step'),
    program: t('specification.program'),
    input: t('specification.input'),
    output: t('specification.output'),
    diagnostics: t('specification.diagnostics'),
    summary: t('specification.summary'),
    seeAlso: t('specification.seeAlso'),
    intermediate: t('specification.intermediate'),
    trace: t('specification.trace'),
    traceLine: t('specification.traceLine'),
    traceEvent: t('specification.traceEvent'),
    webPage: t('specification.webPage'),
  };
}
