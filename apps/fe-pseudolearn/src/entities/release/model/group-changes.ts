import { CHANGE_KINDS, type ChangeKind, type ReleaseChange } from './release';

export interface ChangeGroup {
  readonly kind: ChangeKind;
  readonly changes: readonly ReleaseChange[];
}

export function groupChangesByKind(changes: readonly ReleaseChange[]): readonly ChangeGroup[] {
  return CHANGE_KINDS.map((kind) => ({
    kind,
    changes: changes.filter((change) => change.kind === kind),
  })).filter((group) => group.changes.length > 0);
}
