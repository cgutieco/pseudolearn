import { describe, expect, it } from 'vitest';
import { RELEASES, latestRelease, oldestRelease } from './release-catalog';

describe('release catalog', () => {
  it('publishes the shared changelog with at least one release', () => {
    expect(RELEASES.length).toBeGreaterThan(0);
  });

  it('reads the newest release first and the oldest last', () => {
    expect(latestRelease()).toBe(RELEASES[0]);
    expect(oldestRelease()).toBe(RELEASES[RELEASES.length - 1]);
  });

  it('starts the history at the first stable version', () => {
    expect(oldestRelease().version).toBe('1.0.0');
  });

  it('records the platform change that brought Windows', () => {
    const windowsRelease = RELEASES.find((release) =>
      release.changes.some((change) => change.id === 'windows' && change.kind === 'platform'),
    );
    expect(windowsRelease?.version).toBe('1.1.0');
  });
});
