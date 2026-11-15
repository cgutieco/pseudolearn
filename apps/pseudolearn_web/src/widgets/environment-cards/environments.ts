import type { TranslationKey } from '@shared/i18n/translator';
import type { IconName } from '@shared/ui/icon';

export interface EnvironmentCard {
  readonly id: string;
  readonly icon: IconName;
  readonly available: boolean;
  readonly titleKey: TranslationKey;
  readonly textKey: TranslationKey;
  readonly featureKeys: readonly TranslationKey[];
}

export const ENVIRONMENT_CARDS: readonly EnvironmentCard[] = [
  {
    id: 'app',
    icon: 'laptop',
    available: true,
    titleKey: 'language.env.app.title',
    textKey: 'language.env.app.text',
    featureKeys: ['language.env.app.f1', 'language.env.app.f2', 'language.env.app.f3'],
  },
  {
    id: 'vscode',
    icon: 'code',
    available: false,
    titleKey: 'language.env.vscode.title',
    textKey: 'language.env.vscode.text',
    featureKeys: ['language.env.vscode.f1', 'language.env.vscode.f2', 'language.env.vscode.f3'],
  },
  {
    id: 'cli',
    icon: 'terminal',
    available: false,
    titleKey: 'language.env.cli.title',
    textKey: 'language.env.cli.text',
    featureKeys: ['language.env.cli.f1', 'language.env.cli.f2', 'language.env.cli.f3'],
  },
];
