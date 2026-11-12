import type { TranslationKey } from '@shared/i18n/translator';
export type PlatformAvailability = 'available' | 'comingSoon' | 'planned';

export interface Platform {
  readonly id: string;
  readonly translationKey: TranslationKey;
  readonly availability: PlatformAvailability;
  readonly minimumVersion?: string;
}

export const PLATFORMS: readonly Platform[] = [
  { id: 'macos', translationKey: 'platform.macos', availability: 'available', minimumVersion: '13+' },
  { id: 'ios', translationKey: 'platform.ios', availability: 'available', minimumVersion: '16+' },
  { id: 'windows', translationKey: 'platform.windows', availability: 'available', minimumVersion: '10+' },
  { id: 'vscode', translationKey: 'platform.vscode', availability: 'comingSoon' },
  { id: 'cli', translationKey: 'platform.cli', availability: 'comingSoon' },
  { id: 'linux', translationKey: 'platform.linux', availability: 'planned' },
  { id: 'android', translationKey: 'platform.android', availability: 'planned' },
  { id: 'other', translationKey: 'platform.other', availability: 'planned' },
];

export interface ReportablePlatform {
  readonly id: string;
  readonly translationKey: TranslationKey;
}

export const REPORTABLE_PLATFORMS: readonly ReportablePlatform[] = [
  { id: 'macos', translationKey: 'platform.macos' },
  { id: 'ios', translationKey: 'platform.ios' },
  { id: 'windows-store', translationKey: 'platform.windowsStore' },
  { id: 'windows-installer', translationKey: 'platform.windowsInstaller' },
  { id: 'linux', translationKey: 'platform.linux' },
  { id: 'android', translationKey: 'platform.android' },
  { id: 'other', translationKey: 'platform.other' },
];

export function availablePlatforms(): readonly Platform[] {
  return PLATFORMS.filter((platform) => platform.availability === 'available');
}

export function comingSoonPlatforms(): readonly Platform[] {
  return PLATFORMS.filter((platform) => platform.availability === 'comingSoon');
}

export function plannedPlatforms(): readonly Platform[] {
  return PLATFORMS.filter((platform) => platform.availability === 'planned' && platform.id !== 'other');
}

export function isReportablePlatform(candidate: string): boolean {
  return REPORTABLE_PLATFORMS.some((platform) => platform.id === candidate);
}
