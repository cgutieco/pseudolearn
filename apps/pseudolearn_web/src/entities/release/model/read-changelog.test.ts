import { describe, expect, it } from 'vitest';
import { readChangelog, type ChangelogProblem } from './read-changelog';

function localized(text: string): { es: string; en: string } {
  return { es: `${text} es`, en: `${text} en` };
}

function change(id: string, kind = 'feature'): Record<string, unknown> {
  return { id, kind, title: localized(id), description: localized(`${id} detail`) };
}

function release(version: string, date: string, overrides: Record<string, unknown> = {}) {
  return {
    version,
    date,
    core: '0.1.0',
    headline: localized('headline'),
    summary: localized('summary'),
    changes: [change('windows', 'platform')],
    ...overrides,
  };
}

function rulesOf(problems: readonly ChangelogProblem[]): string[] {
  return problems.map((problem) => `${problem.path}:${problem.rule}`);
}

describe('readChangelog', () => {
  it('reads a valid changelog newest first with both locales', () => {
    const reading = readChangelog({
      releases: [release('1.1.0', '2026-10-01'), release('1.0.0', '2026-09-17')],
    });
    expect(reading.problems).toEqual([]);
    expect(reading.releases.map((entry) => entry.version)).toEqual(['1.1.0', '1.0.0']);
    expect(reading.releases[0]?.changes[0]).toEqual({
      id: 'windows',
      kind: 'platform',
      title: { es: 'windows es', en: 'windows en' },
      description: { es: 'windows detail es', en: 'windows detail en' },
    });
  });

  it('accepts a single release', () => {
    expect(readChangelog({ releases: [release('0.0.1', '2026-01-01')] }).problems).toEqual([]);
  });

  it('rejects a source without releases', () => {
    for (const source of [null, undefined, 'text', [], {}, { releases: [] }, { releases: 'x' }]) {
      expect(rulesOf(readChangelog(source).problems)).toEqual(['releases:shape']);
      expect(readChangelog(source).releases).toEqual([]);
    }
  });

  it('rejects versions and anchored cores that are not semantic', () => {
    const reading = readChangelog({ releases: [release('1.1', '2026-10-01', { core: 'v0.1.0' })] });
    expect(rulesOf(reading.problems)).toEqual([
      'releases[0].core:semantic-version',
      'releases[0].version:semantic-version',
    ]);
    expect(reading.releases).toEqual([]);
  });

  it('rejects dates that are not real calendar days', () => {
    for (const date of ['2026-02-30', '2026-13-01', '01/10/2026', '', 20261001]) {
      const reading = readChangelog({ releases: [release('1.0.0', '2026-01-01', { date })] });
      expect(rulesOf(reading.problems)).toEqual(['releases[0].date:iso-date']);
    }
  });

  it('accepts a leap day', () => {
    expect(readChangelog({ releases: [release('1.0.0', '2028-02-29')] }).problems).toEqual([]);
  });

  it('names every locale missing from a text', () => {
    const reading = readChangelog({
      releases: [release('1.0.0', '2026-01-01', { headline: { es: '  ' }, summary: 'plain' })],
    });
    expect(rulesOf(reading.problems)).toEqual([
      'releases[0].headline.es:localized-text',
      'releases[0].headline.en:localized-text',
      'releases[0].summary.es:localized-text',
      'releases[0].summary.en:localized-text',
    ]);
  });

  it('rejects a release without changes', () => {
    const reading = readChangelog({ releases: [release('1.0.0', '2026-01-01', { changes: [] })] });
    expect(rulesOf(reading.problems)).toEqual(['releases[0].changes:shape']);
  });

  it('rejects an unknown change kind and a change without identifier', () => {
    const reading = readChangelog({
      releases: [release('1.0.0', '2026-01-01', { changes: [change('a', 'refactor'), change(' ')] })],
    });
    expect(rulesOf(reading.problems)).toEqual([
      'releases[0].changes[0].kind:change-kind',
      'releases[0].changes[1].id:shape',
    ]);
  });

  it('rejects a repeated change identifier inside one release', () => {
    const reading = readChangelog({
      releases: [release('1.0.0', '2026-01-01', { changes: [change('a'), change('a', 'fix')] })],
    });
    expect(rulesOf(reading.problems)).toEqual(['releases[0].changes:unique-change']);
  });

  it('rejects releases listed oldest first', () => {
    const reading = readChangelog({
      releases: [release('1.0.0', '2026-09-17'), release('1.1.0', '2026-10-01')],
    });
    expect(rulesOf(reading.problems)).toEqual(['releases[1]:newest-first']);
  });

  it('rejects a repeated version', () => {
    const reading = readChangelog({
      releases: [release('1.0.0', '2026-09-17'), release('1.0.0', '2026-09-17')],
    });
    expect(rulesOf(reading.problems)).toEqual(['releases[1]:newest-first']);
  });

  it('rejects a newer version dated before the older one', () => {
    const reading = readChangelog({
      releases: [release('1.1.0', '2026-09-01'), release('1.0.0', '2026-09-17')],
    });
    expect(rulesOf(reading.problems)).toEqual(['releases[1]:newest-first']);
  });

  it('compares versions numerically, not as text', () => {
    const reading = readChangelog({
      releases: [release('1.10.0', '2026-12-01'), release('1.9.0', '2026-11-01')],
    });
    expect(reading.problems).toEqual([]);
  });
});
