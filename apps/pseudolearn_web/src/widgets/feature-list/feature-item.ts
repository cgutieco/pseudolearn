import type { TranslationKey } from '@shared/i18n/translator';

export interface FeatureItem {
  readonly titleKey: TranslationKey;
  readonly textKey: TranslationKey;
}
