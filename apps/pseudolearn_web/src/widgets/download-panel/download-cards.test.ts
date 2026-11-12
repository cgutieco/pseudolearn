import { describe, expect, it } from 'vitest';
import { SITE } from '@shared/config/site';
import { DOWNLOAD_CARDS, UNSIGNED_WINDOWS_INSTALL_GUIDE } from './download-cards';

describe('DOWNLOAD_CARDS', () => {
  it('offers macOS, mobile and Windows now and announces VS Code and the terminal as coming soon', () => {
    expect(DOWNLOAD_CARDS.map((card) => [card.titleKey, card.available])).toEqual([
      ['download.macTitle', true],
      ['download.mobileTitle', true],
      ['download.windowsTitle', true],
      ['download.vscodeTitle', false],
      ['download.cliTitle', false],
    ]);
  });

  it('gives no download action to an environment that is not published yet', () => {
    for (const card of DOWNLOAD_CARDS.filter((candidate) => !candidate.available)) {
      expect(card.actions).toEqual([]);
      expect(card.textKey).toBeDefined();
    }
  });

  it('configures macOS download exclusively via Mac App Store', () => {
    const macCard = DOWNLOAD_CARDS[0];
    expect(macCard?.actions).toHaveLength(1);

    const primaryAction = macCard?.actions[0];
    expect(primaryAction?.labelKey).toBe('download.macPrimary');
    expect(primaryAction?.variant).toBe('pl-btn--primary');
    expect(primaryAction?.href).toBe(SITE.macAppStoreUrl);
    expect(primaryAction?.external).toBe(true);
  });

  it('configures mobile download via App Store', () => {
    const mobileCard = DOWNLOAD_CARDS[1];
    expect(mobileCard?.actions).toHaveLength(1);

    const primaryAction = mobileCard?.actions[0];
    expect(primaryAction?.labelKey).toBe('download.mobilePrimary');
    expect(primaryAction?.variant).toBe('pl-btn--primary');
    expect(primaryAction?.href).toBe(SITE.iosAppStoreUrl);
    expect(primaryAction?.external).toBe(true);
  });

  it('does not contain any direct dmg action or secondary action for mac', () => {
    const macCard = DOWNLOAD_CARDS[0];
    const actionLabels = macCard?.actions.map((action) => action.labelKey) ?? [];
    expect(actionLabels).toEqual(['download.macPrimary']);
    expect(actionLabels).not.toContain('download.macSecondary');
  });

  it('defines valid specs for every published card', () => {
    for (const card of DOWNLOAD_CARDS.filter((candidate) => candidate.available)) {
      expect(card.specs.length).toBeGreaterThan(0);
      for (const spec of card.specs) {
        expect(spec.labelKey).toBeTruthy();
        expect(spec.valueKey).toBeTruthy();
      }
    }
  });

  it('promotes the Microsoft Store listing first and keeps the direct installer as the alternative', () => {
    const windowsCard = DOWNLOAD_CARDS[2];
    expect(windowsCard?.actions).toEqual([
      {
        labelKey: 'download.windowsPrimary',
        variant: 'pl-btn--primary',
        href: 'https://apps.microsoft.com/store/detail/9MXZB1XDWP9J?cid=DevShareMCLPCS',
        external: true,
      },
      {
        labelKey: 'download.windowsSecondary',
        variant: 'pl-btn--ghost',
        href: 'https://downloads.pseudolearn.app/windows/PseudoLearn-Setup.exe',
      },
    ]);
    expect(SITE.microsoftStoreUrl).toBe(windowsCard?.actions[0]?.href);
    expect(SITE.windowsInstallerUrl).toBe(windowsCard?.actions[1]?.href);
  });

  it('downloads the Windows installer in the same tab because it is a file, not a store listing', () => {
    const installerAction = DOWNLOAD_CARDS[2]?.actions[1];
    expect(installerAction?.external).toBeUndefined();
  });

  it('guides through the SmartScreen warning only where the installer is unsigned', () => {
    expect(DOWNLOAD_CARDS[2]?.guide).toBe(UNSIGNED_WINDOWS_INSTALL_GUIDE);
    expect(DOWNLOAD_CARDS.filter((card) => card.guide !== undefined)).toHaveLength(1);
  });

  it('walks the unsigned installer guide in four ordered steps', () => {
    expect(UNSIGNED_WINDOWS_INSTALL_GUIDE.stepKeys).toEqual([
      'download.windowsGuide.stepBrowser',
      'download.windowsGuide.stepMoreInfo',
      'download.windowsGuide.stepRunAnyway',
      'download.windowsGuide.stepInstall',
    ]);
  });

  it('shows the version of every published card from the shared changelog', () => {
    for (const card of DOWNLOAD_CARDS.filter((candidate) => candidate.available)) {
      const versionSpec = card.specs.find((spec) => spec.labelKey === 'download.specVersion');
      expect(versionSpec?.valueKey).toBe('download.versionValue');
    }
  });
});
