import type { LayoutRule, Slot } from "../catalog/catalog_types.ts";
import type { ContentKind, FrameLayout, PlacedElement } from "../layout/safe_area_check.ts";
import { finding, type Finding } from "./finding.ts";
import { visibleTextOf } from "./visible_text.ts";

export type ContentRulesRequest = {
  readonly slot: Slot;
  readonly frames: readonly FrameLayout[];
  readonly texts: readonly string[];
  readonly html: string;
};

const CONTENT_RULES: readonly LayoutRule[] = ["no-text", "no-interface", "no-added-text"];
const FORBIDDEN: Readonly<Partial<Record<LayoutRule, readonly ContentKind[]>>> = {
  "no-text": ["added-text"],
  "no-interface": ["app-interface"],
  "no-added-text": ["added-text", "added-mark"],
};
const TEXT_FREE_RULES: readonly LayoutRule[] = ["no-text", "no-added-text"];
const TWO_THIRDS = 2 / 3;
const EPSILON = 1e-6;

export function auditContentRules(target: string, request: ContentRulesRequest): readonly Finding[] {
  const elements = request.frames.flatMap((frame) => frame.elements);
  const messages = new Set<string>([
    ...undeclared(request.slot, elements),
    ...forbiddenContent(request.slot, elements),
    ...addedText(request),
    ...belowTwoThirds(request.slot, elements),
  ]);
  return [...messages].map((message) => finding("MEDIA-CONTENT", target, message));
}

function undeclared(slot: Slot, elements: readonly PlacedElement[]): readonly string[] {
  if (!CONTENT_RULES.some((rule) => slot.rules.includes(rule))) {
    return [];
  }
  return elements.filter((element) => element.content === undefined).map((element) => `${element.name} declares no content kind`);
}

function forbiddenContent(slot: Slot, elements: readonly PlacedElement[]): readonly string[] {
  return slot.rules.flatMap((rule) => {
    const forbidden = FORBIDDEN[rule] ?? [];
    return elements
      .filter((element) => element.content !== undefined && forbidden.includes(element.content))
      .map((element) => `${element.name} is ${element.content}, which ${rule} forbids`);
  });
}

function addedText(request: ContentRulesRequest): readonly string[] {
  const rule = TEXT_FREE_RULES.find((entry) => request.slot.rules.includes(entry));
  if (!rule) {
    return [];
  }
  const visible = visibleTextOf(request.html);
  return [
    ...(request.texts.length > 0 ? [`declares texts ${request.texts.map((text) => `"${text}"`).join(", ")}, which ${rule} forbids`] : []),
    ...(visible.length > 0 ? [`the markup shows "${visible.slice(0, 40)}", which ${rule} forbids`] : []),
  ];
}

function belowTwoThirds(slot: Slot, elements: readonly PlacedElement[]): readonly string[] {
  if (!slot.rules.includes("critical-top-two-thirds")) {
    return [];
  }
  const limit = slot.height * TWO_THIRDS + EPSILON;
  return elements
    .filter((element) => element.essential && element.rect.y + element.rect.height > limit)
    .map((element) => `${element.name} is essential but reaches the bottom third`);
}
