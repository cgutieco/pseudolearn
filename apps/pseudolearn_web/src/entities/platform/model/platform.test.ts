import { describe, expect, it } from 'vitest';
import {
  REPORTABLE_PLATFORMS,
  availablePlatforms,
  comingSoonPlatforms,
  isReportablePlatform,
  plannedPlatforms,
} from './platform';

describe('platform', () => {
  it('announces Windows once among the available platforms', () => {
    expect(availablePlatforms().map((platform) => platform.id)).toEqual(['macos', 'ios', 'windows']);
  });

  it('announces the editor extension and the command line as coming soon', () => {
    expect(comingSoonPlatforms().map((platform) => platform.id)).toEqual(['vscode', 'cli']);
  });

  it('lists the planned platforms without the catch-all option', () => {
    expect(plannedPlatforms().map((platform) => platform.id)).toEqual(['linux', 'android']);
  });

  it('reports Windows by distribution channel so support knows how the app was installed', () => {
    expect(REPORTABLE_PLATFORMS.map((platform) => platform.id)).toEqual([
      'macos',
      'ios',
      'windows-store',
      'windows-installer',
      'linux',
      'android',
      'other',
    ]);
  });

  it('recognises every reportable platform', () => {
    for (const platform of REPORTABLE_PLATFORMS) {
      expect(isReportablePlatform(platform.id)).toBe(true);
    }
  });

  it('rejects unknown, empty and bare Windows identifiers', () => {
    expect(isReportablePlatform('beos')).toBe(false);
    expect(isReportablePlatform('')).toBe(false);
    expect(isReportablePlatform('windows')).toBe(false);
  });
});
