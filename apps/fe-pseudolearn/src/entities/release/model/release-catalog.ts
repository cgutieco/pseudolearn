import changelog from '@changelog';
import { readChangelog } from './read-changelog';
import type { Release } from './release';

type ReleaseList = readonly [Release, ...Release[]];

function loadReleases(): ReleaseList {
  const reading = readChangelog(changelog);
  const [latest, ...older] = reading.releases;
  if (latest === undefined) {
    const details = reading.problems.map((problem) => `${problem.path} (${problem.rule})`).join(', ');
    throw new Error(`CHANGELOG.json cannot be published: ${details}`);
  }
  return [latest, ...older];
}

export const RELEASES: ReleaseList = loadReleases();

export function latestRelease(): Release {
  return RELEASES[0];
}

export function oldestRelease(): Release {
  return RELEASES[RELEASES.length - 1] ?? RELEASES[0];
}
