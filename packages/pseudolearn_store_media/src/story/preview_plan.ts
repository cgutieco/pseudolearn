import type { Beat, Storyboard } from "./storyboard.ts";
import { beatsFromTimeline, type PlatePoint, type PlateTimeline } from "./plate_timeline.ts";
import type { BrandCards, Disclosure } from "./preview_brand.ts";
import type { Caption, PreviewPin } from "./preview_overlays.ts";
import type { LocalizedText } from "./screenshot_story.ts";
import type { Preview, PreviewScene } from "./preview_story.ts";

export type PlacedScene = {
  readonly index: number;
  readonly scene: PreviewScene;
  readonly timeline: PlateTimeline;
  readonly startSeconds: number;
  readonly endSeconds: number;
  readonly dissolveSeconds: number;
};

export type Timed<T> = { readonly sceneIndex: number; readonly startSeconds: number; readonly endSeconds: number; readonly item: T };

export type BrandCard = { readonly kind: "opening" | "closing"; readonly disclosure: LocalizedText | null };

export type PreviewFrame = { readonly brand: BrandCards | null; readonly disclosure: Disclosure | null };

export type PreviewPlan = {
  readonly id: string;
  readonly durationSeconds: number;
  readonly posterSeconds: number;
  readonly scenes: readonly PlacedScene[];
  readonly captions: readonly Timed<Caption>[];
  readonly pins: readonly Timed<PreviewPin>[];
  readonly touches: readonly Timed<PlatePoint>[];
  readonly cards: readonly Timed<BrandCard>[];
  readonly needsDisclosure: boolean;
  readonly beats: readonly Beat[];
};

export const TOUCH_SECONDS = 0.6;
const MELODY = [0, 2, 4, 5, 7, 4, 2, 9];

const NO_FRAME: PreviewFrame = { brand: null, disclosure: null };

export function planPreview(preview: Preview, timelines: readonly PlateTimeline[], frame: PreviewFrame = NO_FRAME): PreviewPlan {
  const scenes: PlacedScene[] = [];
  preview.scenes.forEach((scene, index) => {
    const timeline = timelines[index];
    if (!timeline) {
      return;
    }
    const dissolveSeconds = scene.transition?.seconds ?? 0;
    const startSeconds = Math.max(0, (scenes[index - 1]?.endSeconds ?? 0) - dissolveSeconds);
    scenes.push({ index, scene, timeline, startSeconds, endSeconds: startSeconds + scene.toSeconds - scene.fromSeconds, dissolveSeconds });
  });
  const durationSeconds = scenes[scenes.length - 1]?.endSeconds ?? 0;
  const needsDisclosure = scenes.some((placed) => frame.disclosure?.plates.includes(placed.scene.plate) ?? false);
  return {
    id: preview.id,
    durationSeconds,
    posterSeconds: preview.posterSeconds,
    scenes,
    captions: scenes.flatMap((placed) => placed.scene.captions.map((caption) => timedOverlay(placed, caption))),
    pins: scenes.flatMap((placed) => placed.scene.pins.map((pin) => timedOverlay(placed, pin))),
    touches: scenes.flatMap(touchesOf),
    cards: cardsOf(frame, { durationSeconds, lastScene: Math.max(0, scenes.length - 1), disclosure: needsDisclosure ? frame.disclosure?.text ?? null : null }),
    needsDisclosure,
    beats: scenes.flatMap(beatsOf).sort((first, second) => first.atSeconds - second.atSeconds),
  };
}

export function previewStoryboard(plan: PreviewPlan): Storyboard {
  return { id: plan.id, durationSeconds: plan.durationSeconds, beats: plan.beats };
}

export function plateSecondsAt(placed: PlacedScene, seconds: number): number {
  return placed.scene.fromSeconds + seconds - placed.startSeconds;
}

export function scenesAt(plan: PreviewPlan, seconds: number): readonly PlacedScene[] {
  return plan.scenes.filter((placed) => seconds >= placed.startSeconds && seconds < placed.endSeconds);
}

function timedOverlay<T extends { fromSeconds: number; toSeconds: number }>(placed: PlacedScene, item: T): Timed<T> {
  return { sceneIndex: placed.index, startSeconds: placed.startSeconds + item.fromSeconds, endSeconds: placed.startSeconds + item.toSeconds, item };
}

function eventsInScene(placed: PlacedScene) {
  const { timeline, scene } = placed;
  return timeline.events
    .map((event) => ({ event, plateSeconds: event.frame / timeline.fps }))
    .filter(({ plateSeconds }) => plateSeconds >= scene.fromSeconds && plateSeconds < scene.toSeconds)
    .map(({ event, plateSeconds }) => ({ event, atSeconds: placed.startSeconds + plateSeconds - scene.fromSeconds }));
}

function touchesOf(placed: PlacedScene): readonly Timed<PlatePoint>[] {
  if (!placed.scene.touches) {
    return [];
  }
  return eventsInScene(placed).flatMap(({ event, atSeconds }) => (event.point
    ? [{ sceneIndex: placed.index, startSeconds: atSeconds, endSeconds: Math.min(atSeconds + TOUCH_SECONDS, placed.endSeconds), item: event.point }]
    : []));
}

function beatsOf(placed: PlacedScene): readonly Beat[] {
  const melody = MELODY.slice(placed.index % MELODY.length).concat(MELODY);
  const fromEvents = eventsInScene(placed).map(({ event, atSeconds }, position) => ({
    ...(beatsFromTimeline({ ...placed.timeline, events: [event] }, [melody[position % melody.length] ?? 0])[0] as Beat),
    atSeconds,
  }));
  const entrance: Beat = { atSeconds: placed.startSeconds, kind: "accent", degree: melody[0] ?? 0, weight: 1 };
  return [entrance, ...fromEvents.filter((beat) => beat.atSeconds > placed.startSeconds)];
}

function cardsOf(frame: PreviewFrame, context: { durationSeconds: number; lastScene: number; disclosure: LocalizedText | null }): readonly Timed<BrandCard>[] {
  const brand = frame.brand;
  if (!brand || context.durationSeconds === 0) {
    return [];
  }
  const cards: Timed<BrandCard>[] = [];
  if (brand.openingSeconds > 0) {
    cards.push({ sceneIndex: 0, startSeconds: 0, endSeconds: brand.openingSeconds, item: { kind: "opening", disclosure: null } });
  }
  if (brand.closingSeconds > 0) {
    cards.push({ sceneIndex: context.lastScene, startSeconds: context.durationSeconds - brand.closingSeconds, endSeconds: context.durationSeconds,
      item: { kind: "closing", disclosure: context.disclosure } });
  }
  return cards;
}
