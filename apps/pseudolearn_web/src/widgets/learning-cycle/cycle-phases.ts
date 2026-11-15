import type { TranslationKey } from '@shared/i18n/translator';

export interface CyclePhase {
  readonly number: number;
  readonly titleKey: TranslationKey;
  readonly textKey: TranslationKey;
}

export const CYCLE_PHASES: readonly CyclePhase[] = [
  { number: 1, titleKey: 'cycle.understand.title', textKey: 'cycle.understand.text' },
  { number: 2, titleKey: 'cycle.plan.title', textKey: 'cycle.plan.text' },
  { number: 3, titleKey: 'cycle.write.title', textKey: 'cycle.write.text' },
  { number: 4, titleKey: 'cycle.test.title', textKey: 'cycle.test.text' },
  { number: 5, titleKey: 'cycle.improve.title', textKey: 'cycle.improve.text' },
];
