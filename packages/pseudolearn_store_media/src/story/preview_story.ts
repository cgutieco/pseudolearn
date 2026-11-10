import type { Language, Parsed } from "../catalog/catalog_types.ts";
import { JsonReader, type JsonObject } from "../catalog/json_reader.ts";
import { parseBrandCards, parseDisclosure, type BrandCards, type Disclosure } from "./preview_brand.ts";
import { parseCaptions, parsePins, type Caption, type PreviewPin } from "./preview_overlays.ts";
import { APP_THEMES, PALETTES, type AppTheme, type PaletteId } from "./screenshot_story.ts";

export const TRANSITION_KINDS = ["dissolve"] as const;
export type TransitionKind = (typeof TRANSITION_KINDS)[number];

export type Transition = { readonly kind: TransitionKind; readonly seconds: number };

export type PreviewScene = {
  readonly plate: string;
  readonly appTheme: AppTheme;
  readonly palette: PaletteId;
  readonly fromSeconds: number;
  readonly toSeconds: number;
  readonly transition: Transition | null;
  readonly touches: boolean;
  readonly captions: readonly Caption[];
  readonly pins: readonly PreviewPin[];
};

export type Preview = {
  readonly id: string;
  readonly posterSeconds: number;
  readonly scenes: readonly PreviewScene[];
};

export type PreviewStory = {
  readonly id: string;
  readonly brand: BrandCards | null;
  readonly disclosure: Disclosure | null;
  readonly previews: readonly Preview[];
};

const STORY_KEYS = ["id", "brand", "disclosure", "previews"];
const PREVIEW_KEYS = ["id", "posterSeconds", "scenes"];
const SCENE_KEYS = ["plate", "appTheme", "palette", "from", "to", "transition", "touches", "captions", "pins"];
const SECONDS = { min: 0, max: 600 };
export const MAXIMUM_PREVIEWS = 3;

export function parsePreviewStory(document: unknown): Parsed<PreviewStory> {
  const reader = new JsonReader();
  const root = reader.object(document, "$");
  reader.keys(root, "$", STORY_KEYS);
  const previews = reader.array(root["previews"], "previews")
    .map((value, index) => parsePreview(reader, reader.object(value, `previews[${index}]`), `previews[${index}]`));
  if (previews.length === 0 || previews.length > MAXIMUM_PREVIEWS) {
    reader.fail("previews", `a story holds 1 to ${MAXIMUM_PREVIEWS} previews per device and language`);
  }
  if (new Set(previews.map((preview) => preview.id)).size !== previews.length) {
    reader.fail("previews", "preview ids must be unique");
  }
  const story = {
    id: reader.text(root["id"], "id"),
    brand: parseBrandCards(reader, root["brand"], "brand"),
    disclosure: parseDisclosure(reader, root["disclosure"], "disclosure"),
    previews,
  };
  return reader.errors.length === 0 ? { ok: true, value: story } : { ok: false, errors: reader.errors };
}

export function previewPlatePathParts(scene: PreviewScene, place: { device: string; language: Language }): readonly string[] {
  return [scene.plate, place.device, scene.appTheme, place.language];
}

function parsePreview(reader: JsonReader, entry: JsonObject, path: string): Preview {
  reader.keys(entry, path, PREVIEW_KEYS);
  const scenes = reader.array(entry["scenes"], `${path}.scenes`)
    .map((value, index) => parseScene(reader, reader.object(value, `${path}.scenes[${index}]`), `${path}.scenes[${index}]`));
  if (scenes.length === 0) {
    reader.fail(`${path}.scenes`, "a preview needs at least one scene");
  }
  scenes.forEach((scene, index) => {
    if ((index === 0) !== (scene.transition === null)) {
      reader.fail(`${path}.scenes[${index}].transition`, "every scene but the first enters with a transition, and only those");
    }
  });
  return {
    id: reader.text(entry["id"], `${path}.id`),
    posterSeconds: reader.number(entry["posterSeconds"], `${path}.posterSeconds`, SECONDS),
    scenes,
  };
}

function parseScene(reader: JsonReader, entry: JsonObject, path: string): PreviewScene {
  reader.keys(entry, path, SCENE_KEYS);
  const fromSeconds = reader.number(entry["from"], `${path}.from`, SECONDS);
  const toSeconds = reader.number(entry["to"], `${path}.to`, SECONDS);
  if (toSeconds <= fromSeconds) {
    reader.fail(`${path}.to`, "a scene must end after it starts");
  }
  return {
    plate: reader.text(entry["plate"], `${path}.plate`),
    appTheme: reader.member(entry["appTheme"], `${path}.appTheme`, APP_THEMES),
    palette: reader.member(entry["palette"], `${path}.palette`, PALETTES),
    fromSeconds,
    toSeconds,
    transition: entry["transition"] === undefined ? null : parseTransition(reader, entry["transition"], `${path}.transition`),
    touches: entry["touches"] === undefined ? false : entry["touches"] === true,
    captions: parseCaptions(reader, entry["captions"] ?? [], `${path}.captions`),
    pins: parsePins(reader, entry["pins"] ?? [], `${path}.pins`),
  };
}

function parseTransition(reader: JsonReader, value: unknown, path: string): Transition {
  const entry = reader.object(value, path);
  reader.keys(entry, path, ["kind", "seconds"]);
  return {
    kind: reader.member(entry["kind"], `${path}.kind`, TRANSITION_KINDS),
    seconds: reader.number(entry["seconds"], `${path}.seconds`, { min: 0.01, max: 5 }),
  };
}
