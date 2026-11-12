import { describe, expect, it } from 'vitest';
import { groupChangesByKind } from './group-changes';
import type { ChangeKind, ReleaseChange } from './release';

function change(id: string, kind: ChangeKind): ReleaseChange {
  return { id, kind, title: { es: id, en: id }, description: { es: id, en: id } };
}

describe('groupChangesByKind', () => {
  it('groups changes in the declared kind order and keeps their order inside a group', () => {
    const groups = groupChangesByKind([
      change('crash', 'fix'),
      change('windows', 'platform'),
      change('loops', 'feature'),
      change('arrays', 'feature'),
    ]);
    expect(groups.map((group) => group.kind)).toEqual(['feature', 'platform', 'fix']);
    expect(groups[0]?.changes.map((entry) => entry.id)).toEqual(['loops', 'arrays']);
  });

  it('leaves out kinds without changes', () => {
    const groups = groupChangesByKind([change('windows', 'platform')]);
    expect(groups.map((group) => group.kind)).toEqual(['platform']);
  });

  it('returns no groups for no changes', () => {
    expect(groupChangesByKind([])).toEqual([]);
  });
});
