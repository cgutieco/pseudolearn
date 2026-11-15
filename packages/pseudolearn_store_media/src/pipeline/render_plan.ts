import type { Catalog, Language, Slot } from "../catalog/catalog_types.ts";

export type Job = {
  readonly slot: Slot;
  readonly language: Language;
  readonly locales: readonly string[];
  readonly directory: string;
};

export type PlanRequest = {
  readonly catalog: Catalog;
  readonly slotIds: readonly string[];
  readonly languages: readonly Language[];
};

export type PlanResult = { readonly jobs: readonly Job[]; readonly unknownSlots: readonly string[] };

export function planJobs(request: PlanRequest): PlanResult {
  const { catalog, slotIds, languages } = request;
  const selected = slotIds.length === 0 ? catalog.slots : catalog.slots.filter((slot) => slotIds.includes(slot.id));
  const unknownSlots = slotIds.filter((id) => !catalog.slots.some((slot) => slot.id === id));
  const jobs = selected.flatMap((slot) => languages.map((language) => ({
    slot,
    language,
    locales: catalog.localesByLanguage[slot.store][language],
    directory: `${slot.store}/${slot.id}/${language}`,
  })));
  return { jobs, unknownSlots };
}
