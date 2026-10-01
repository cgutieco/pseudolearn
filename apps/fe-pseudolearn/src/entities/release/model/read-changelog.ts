import { LOCALES } from '@shared/i18n/locales';
import {
  CHANGE_KINDS,
  type ChangeKind,
  type LocalizedText,
  type Release,
  type ReleaseChange,
} from './release';

export type ChangelogRule =
  | 'shape'
  | 'semantic-version'
  | 'iso-date'
  | 'localized-text'
  | 'change-kind'
  | 'unique-change'
  | 'newest-first';

export interface ChangelogProblem {
  readonly path: string;
  readonly rule: ChangelogRule;
}

export interface ChangelogReading {
  readonly releases: readonly Release[];
  readonly problems: readonly ChangelogProblem[];
}

type Entry = Record<string, unknown>;

const SEMANTIC_VERSION = /^(\d+)\.(\d+)\.(\d+)$/;
const ISO_DATE = /^\d{4}-\d{2}-\d{2}$/;

export function readChangelog(source: unknown): ChangelogReading {
  const releases = isEntry(source) ? source.releases : undefined;
  if (!Array.isArray(releases) || releases.length === 0) {
    return { releases: [], problems: [{ path: 'releases', rule: 'shape' }] };
  }
  const problems: ChangelogProblem[] = [];
  const read = releases.map((entry: unknown, index) => readRelease(entry, `releases[${index}]`, problems));
  problems.push(...findOrderProblems(read));
  return { releases: problems.length === 0 ? read : [], problems };
}

function readRelease(source: unknown, path: string, problems: ChangelogProblem[]): Release {
  const entry = isEntry(source) ? source : {};
  const changes = Array.isArray(entry.changes) ? entry.changes : [];
  if (changes.length === 0) problems.push({ path: `${path}.changes`, rule: 'shape' });
  expectVersion(entry.core, `${path}.core`, problems);
  return {
    version: expectVersion(entry.version, `${path}.version`, problems),
    date: expectDate(entry.date, `${path}.date`, problems),
    headline: expectLocalized(entry.headline, `${path}.headline`, problems),
    summary: expectLocalized(entry.summary, `${path}.summary`, problems),
    changes: readChanges(changes, `${path}.changes`, problems),
  };
}

function readChanges(sources: unknown[], path: string, problems: ChangelogProblem[]): ReleaseChange[] {
  const changes = sources.map((source, index) => readChange(source, `${path}[${index}]`, problems));
  const identifiers = changes.map((change) => change.id);
  if (new Set(identifiers).size !== identifiers.length) problems.push({ path, rule: 'unique-change' });
  return changes;
}

function readChange(source: unknown, path: string, problems: ChangelogProblem[]): ReleaseChange {
  const entry = isEntry(source) ? source : {};
  const id = typeof entry.id === 'string' ? entry.id.trim() : '';
  if (id === '') problems.push({ path: `${path}.id`, rule: 'shape' });
  return {
    id,
    kind: expectKind(entry.kind, `${path}.kind`, problems),
    title: expectLocalized(entry.title, `${path}.title`, problems),
    description: expectLocalized(entry.description, `${path}.description`, problems),
  };
}

function expectVersion(value: unknown, path: string, problems: ChangelogProblem[]): string {
  if (typeof value === 'string' && SEMANTIC_VERSION.test(value)) return value;
  problems.push({ path, rule: 'semantic-version' });
  return '';
}

function expectDate(value: unknown, path: string, problems: ChangelogProblem[]): string {
  if (typeof value === 'string' && isCalendarDate(value)) return value;
  problems.push({ path, rule: 'iso-date' });
  return '';
}

function expectKind(value: unknown, path: string, problems: ChangelogProblem[]): ChangeKind {
  const kind = CHANGE_KINDS.find((candidate) => candidate === value);
  if (kind !== undefined) return kind;
  problems.push({ path, rule: 'change-kind' });
  return CHANGE_KINDS[0];
}

function expectLocalized(value: unknown, path: string, problems: ChangelogProblem[]): LocalizedText {
  const entry = isEntry(value) ? value : {};
  const text = (locale: string): string =>
    typeof entry[locale] === 'string' ? String(entry[locale]).trim() : '';
  const missing = LOCALES.filter((locale) => text(locale) === '');
  for (const locale of missing) problems.push({ path: `${path}.${locale}`, rule: 'localized-text' });
  return { es: text('es'), en: text('en') };
}

function findOrderProblems(releases: readonly Release[]): ChangelogProblem[] {
  return releases.slice(1).flatMap((release, index) => {
    const newer = releases[index];
    if (newer === undefined || release.version === '' || newer.version === '') return [];
    const ordered = compareVersions(newer.version, release.version) > 0 && newer.date >= release.date;
    return ordered ? [] : [{ path: `releases[${index + 1}]`, rule: 'newest-first' as const }];
  });
}

function isCalendarDate(value: string): boolean {
  if (!ISO_DATE.test(value)) return false;
  const parsed = new Date(`${value}T00:00:00Z`);
  return !Number.isNaN(parsed.getTime()) && parsed.toISOString().startsWith(value);
}

function compareVersions(left: string, right: string): number {
  const rightParts = versionParts(right);
  const difference = versionParts(left)
    .map((part, index) => part - (rightParts[index] ?? 0))
    .find((delta) => delta !== 0);
  return difference ?? 0;
}

function versionParts(version: string): number[] {
  return (SEMANTIC_VERSION.exec(version) ?? []).slice(1).map(Number);
}

function isEntry(value: unknown): value is Entry {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}
