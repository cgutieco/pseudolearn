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
  readonly titleKey: TranslationKey;
  readonly leadKey: TranslationKey;
  readonly stepKeys: readonly TranslationKey[];
  readonly noteKey: TranslationKey;
}

export interface DownloadCardModel {
  readonly icon: IconName;
  readonly titleKey: TranslationKey;
  readonly actions: readonly DownloadAction[];
  readonly specs: readonly DownloadSpec[];
  readonly guide?: InstallGuideModel;
}

export const UNSIGNED_WINDOWS_INSTALL_GUIDE: InstallGuideModel = {
  titleKey: 'home.downloads.windowsGuide.title',
  leadKey: 'home.downloads.windowsGuide.lead',
  stepKeys: [
    'home.downloads.windowsGuide.stepBrowser',
    'home.downloads.windowsGuide.stepMoreInfo',
    'home.downloads.windowsGuide.stepRunAnyway',
    'home.downloads.windowsGuide.stepInstall',
  ],
  noteKey: 'home.downloads.windowsGuide.note',
};

export const DOWNLOAD_CARDS: readonly DownloadCardModel[] = [
  {
    icon: 'laptop',
    titleKey: 'home.downloads.macTitle',
    actions: [
      {
        labelKey: 'home.downloads.macPrimary',
        variant: 'pl-btn--primary',
        href: SITE.macAppStoreUrl,
        external: true,
      },
    ],
    specs: [
      { labelKey: 'home.downloads.specRequirements', valueKey: 'home.downloads.macRequirements' },
      { labelKey: 'home.downloads.specArchitecture', valueKey: 'home.downloads.macArchitecture' },
      { labelKey: 'home.downloads.specVersion', valueKey: 'home.downloads.versionValue' },
      { labelKey: 'home.downloads.specPrice', valueKey: 'home.downloads.priceValue' },
    ],
  },
  {
    icon: 'phone',
    titleKey: 'home.downloads.mobileTitle',
    actions: [
      {
        labelKey: 'home.downloads.mobilePrimary',
        variant: 'pl-btn--primary',
        href: SITE.iosAppStoreUrl,
        external: true,
      },
    ],
    specs: [
      { labelKey: 'home.downloads.specRequirements', valueKey: 'home.downloads.mobileRequirements' },
      { labelKey: 'home.downloads.specInput', valueKey: 'home.downloads.mobileInput' },
      { labelKey: 'home.downloads.specVersion', valueKey: 'home.downloads.versionValue' },
      { labelKey: 'home.downloads.specPrice', valueKey: 'home.downloads.priceValue' },
    ],
  },
  {
    icon: 'monitor',
    titleKey: 'home.downloads.windowsTitle',
    actions: [
      {
        labelKey: 'home.downloads.windowsPrimary',
        variant: 'pl-btn--primary',
        href: SITE.windowsInstallerUrl,
      },
    ],
    specs: [
      { labelKey: 'home.downloads.specRequirements', valueKey: 'home.downloads.windowsRequirements' },
      { labelKey: 'home.downloads.specInstallation', valueKey: 'home.downloads.windowsInstallation' },
      { labelKey: 'home.downloads.specVersion', valueKey: 'home.downloads.versionValue' },
      { labelKey: 'home.downloads.specPrice', valueKey: 'home.downloads.priceValue' },
    ],
    guide: UNSIGNED_WINDOWS_INSTALL_GUIDE,
  },
];
