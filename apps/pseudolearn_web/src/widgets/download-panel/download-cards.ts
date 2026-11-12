import { SITE } from '@shared/config/site';
import type { TranslationKey } from '@shared/i18n/translator';
import type { IconName } from '@shared/ui/icon';

export interface DownloadAction {
  readonly labelKey: TranslationKey;
  readonly variant: string;
  readonly href?: string;
  readonly external?: boolean;
}

export interface DownloadSpec {
  readonly labelKey: TranslationKey;
  readonly valueKey: TranslationKey;
}

export interface InstallGuideModel {
  readonly summaryKey: TranslationKey;
  readonly leadKey: TranslationKey;
  readonly stepKeys: readonly TranslationKey[];
  readonly noteKey: TranslationKey;
}

export interface DownloadCardModel {
  readonly icon: IconName;
  readonly available: boolean;
  readonly textKey?: TranslationKey;
  readonly titleKey: TranslationKey;
  readonly actions: readonly DownloadAction[];
  readonly specs: readonly DownloadSpec[];
  readonly guide?: InstallGuideModel;
}

export const UNSIGNED_WINDOWS_INSTALL_GUIDE: InstallGuideModel = {
  summaryKey: 'download.windowsGuide.summary',
  leadKey: 'download.windowsGuide.lead',
  stepKeys: [
    'download.windowsGuide.stepBrowser',
    'download.windowsGuide.stepMoreInfo',
    'download.windowsGuide.stepRunAnyway',
    'download.windowsGuide.stepInstall',
  ],
  noteKey: 'download.windowsGuide.note',
};

export const DOWNLOAD_CARDS: readonly DownloadCardModel[] = [
  {
    icon: 'laptop',
    available: true,
    titleKey: 'download.macTitle',
    actions: [
      {
        labelKey: 'download.macPrimary',
        variant: 'pl-btn--primary',
        href: SITE.macAppStoreUrl,
        external: true,
      },
    ],
    specs: [
      { labelKey: 'download.specRequirements', valueKey: 'download.macRequirements' },
      { labelKey: 'download.specArchitecture', valueKey: 'download.macArchitecture' },
      { labelKey: 'download.specVersion', valueKey: 'download.versionValue' },
      { labelKey: 'download.specPrice', valueKey: 'download.priceValue' },
    ],
  },
  {
    icon: 'phone',
    available: true,
    titleKey: 'download.mobileTitle',
    actions: [
      {
        labelKey: 'download.mobilePrimary',
        variant: 'pl-btn--primary',
        href: SITE.iosAppStoreUrl,
        external: true,
      },
    ],
    specs: [
      { labelKey: 'download.specRequirements', valueKey: 'download.mobileRequirements' },
      { labelKey: 'download.specInput', valueKey: 'download.mobileInput' },
      { labelKey: 'download.specVersion', valueKey: 'download.versionValue' },
      { labelKey: 'download.specPrice', valueKey: 'download.priceValue' },
    ],
  },
  {
    icon: 'monitor',
    available: true,
    titleKey: 'download.windowsTitle',
    actions: [
      {
        labelKey: 'download.windowsPrimary',
        variant: 'pl-btn--primary',
        href: SITE.microsoftStoreUrl,
        external: true,
      },
      {
        labelKey: 'download.windowsSecondary',
        variant: 'pl-btn--ghost',
        href: SITE.windowsInstallerUrl,
      },
    ],
    specs: [
      { labelKey: 'download.specRequirements', valueKey: 'download.windowsRequirements' },
      { labelKey: 'download.specDistribution', valueKey: 'download.windowsDistribution' },
      { labelKey: 'download.specInstallation', valueKey: 'download.windowsInstallation' },
      { labelKey: 'download.specVersion', valueKey: 'download.versionValue' },
      { labelKey: 'download.specPrice', valueKey: 'download.priceValue' },
    ],
    guide: UNSIGNED_WINDOWS_INSTALL_GUIDE,
  },
  {
    icon: 'code',
    available: false,
    titleKey: 'download.vscodeTitle',
    textKey: 'download.vscodeText',
    actions: [],
    specs: [{ labelKey: 'download.specRequirements', valueKey: 'download.vscodeRequirements' }],
  },
  {
    icon: 'terminal',
    available: false,
    titleKey: 'download.cliTitle',
    textKey: 'download.cliText',
    actions: [],
    specs: [],
  },
];
