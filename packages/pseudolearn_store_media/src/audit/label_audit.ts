import type { Catalog, LabelKind, Language, Slot } from "../catalog/catalog_types.ts";
import { finding, type Finding } from "./finding.ts";
import { auditLexicon } from "./text_audit.ts";

export type Label = { readonly kind: LabelKind; readonly language: Language; readonly text: string };

export function auditLabels(catalog: Catalog, slot: Slot, labels: readonly Label[]): readonly Finding[] {
  return labels.flatMap((label) => [...lengthFindings(slot, label), ...auditLexicon(catalog, slot.store, [label.text])]);
}

export function characterCount(text: string): number {
  return [...text.normalize("NFC")].length;
}

function lengthFindings(slot: Slot, label: Label): readonly Finding[] {
  const limit = slot.labelLimits[label.kind];
  const target = `${slot.id} ${label.kind} ${label.language}`;
  if (limit === undefined) {
    return [finding("TEXT-LENGTH", target, `${slot.id} takes no ${label.kind}`)];
  }
  const count = characterCount(label.text);
  if (label.text.trim().length === 0) {
    return [finding("TEXT-LENGTH", target, `the ${label.kind} is empty`)];
  }
  return count > limit ? [finding("TEXT-LENGTH", target, `${count} characters exceed ${limit}`)] : [];
}
