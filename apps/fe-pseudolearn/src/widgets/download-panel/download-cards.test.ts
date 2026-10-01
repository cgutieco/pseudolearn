import { describe, expect, it } from 'vitest';
import { SITE } from '@shared/config/site';
import { DOWNLOAD_CARDS, UNSIGNED_WINDOWS_INSTALL_GUIDE } from './download-cards';

describe('DOWNLOAD_CARDS', () => {
  it('contains exactly macOS, mobile and Windows download cards', () => {
    expect(DOWNLOAD_CARDS.map((card) => card.titleKey)).toEqual([
      'home.downloads.macTitle',
      'home.downloads.mobileTitle',
      'home.downloads.windowsTitle',
    ]);
  });

  it('configures macOS download exclusively via Mac App Store', () => {
    const macCard = DOWNLOAD_CARDS[0];
    expect(macCard?.actions).toHaveLength(1);

    const primaryAction = macCard?.actions[0];
    expect(primaryAction?.labelKey).toBe('home.downloads.macPrimary');
    expect(primaryAction?.variant).toBe('pl-btn--primary');
    expect(primaryAction?.href).toBe(SITE.macAppStoreUrl);
    expect(primaryAction?.external).toBe(true);
  });

  it('configures mobile download via App Store', () => {
    const mobileCard = DOWNLOAD_CARDS[1];
    expect(mobileCard?.actions).toHaveLength(1);

    const primaryAction = mobileCard?.actions[0];
    expect(primaryAction?.labelKey).toBe('home.downloads.mobilePrimary');
    expect(primaryAction?.variant).toBe('pl-btn--primary');
    expect(primaryAction?.href).toBe(SITE.iosAppStoreUrl);
    expect(primaryAction?.external).toBe(true);
  });

  it('does not contain any direct dmg action or secondary action for mac', () => {
    const macCard = DOWNLOAD_CARDS[0];
    const actionLabels = macCard?.actions.map((action) => action.labelKey) ?? [];
    expect(actionLabels).toEqual(['home.downloads.macPrimary']);
    expect(actionLabels).not.toContain('home.downloads.macSecondary');
  });

  it('defines valid specs for all cards', () => {
    for (const card of DOWNLOAD_CARDS) {
      expect(card.specs.length).toBeGreaterThan(0);
      for (const spec of card.specs) {
        expect(spec.labelKey).toBeTruthy();
        expect(spec.valueKey).toBeTruthy();
      }
    }
  });

  it('downloads the Windows installer directly in the same tab', () => {
    const windowsCard = DOWNLOAD_CARDS[2];
    expect(windowsCard?.actions).toEqual([
      {
        labelKey: 'home.downloads.windowsPrimary',
        variant: 'pl-btn--primary',
        href: 'https://downloads.pseudolearn.app/windows/PseudoLearn-Setup.exe',
      },
    ]);
    expect(SITE.windowsInstallerUrl).toBe(windowsCard?.actions[0]?.href);
  });

  it('guides through the SmartScreen warning only where the installer is unsigned', () => {
    expect(DOWNLOAD_CARDS[2]?.guide).toBe(UNSIGNED_WINDOWS_INSTALL_GUIDE);
    expect(DOWNLOAD_CARDS.filter((card) => card.guide !== undefined)).toHaveLength(1);
  });

  it('walks the unsigned installer guide in four ordered steps', () => {
    expect(UNSIGNED_WINDOWS_INSTALL_GUIDE.stepKeys).toEqual([
      'home.downloads.windowsGuide.stepBrowser',
      'home.downloads.windowsGuide.stepMoreInfo',
      'home.downloads.windowsGuide.stepRunAnyway',
      'home.downloads.windowsGuide.stepInstall',
    ]);
  });

  it('shows the version of every card from the shared changelog', () => {
    for (const card of DOWNLOAD_CARDS) {
      const versionSpec = card.specs.find((spec) => spec.labelKey === 'home.downloads.specVersion');
      expect(versionSpec?.valueKey).toBe('home.downloads.versionValue');
    }
  });
});
