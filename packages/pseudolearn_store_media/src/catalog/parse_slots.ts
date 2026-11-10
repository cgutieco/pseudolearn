import {
  ASSET_KINDS,
  AUDIO_POLICIES,
  LAYOUT_RULES,
  STORES,
  type CodecProfile,
  type Device,
  type NormalizedRect,
  type Slot,
  type VideoTraits,
} from "./catalog_types.ts";
import type { JsonObject, JsonReader } from "./json_reader.ts";

const SLOT_KEYS = ["id", "store", "surface", "kind", "width", "height", "maxCount", "maxBytes", "safeArea", "rules", "video", "device"];
const VIDEO_KEYS = ["fps", "acceptedFps", "duration", "codecProfile", "audio"];
const APPLE_MAX_BYTES = 524_288_000;
const FULL_CANVAS: NormalizedRect = { x: 0, y: 0, width: 1, height: 1 };
const VIDEO_KINDS = new Set(["app-preview", "header-video", "search-video", "trailer"]);

export type SlotContext = {
  readonly reader: JsonReader;
  readonly profiles: ReadonlyMap<string, CodecProfile>;
  readonly devices: ReadonlyMap<string, Device>;
};

export function parseSlots(context: SlotContext, document: JsonObject): readonly Slot[] {
  const entries = context.reader.array(document["slots"], "slots");
  const slots = entries.map((entry, index) => parseSlot(context, context.reader.object(entry, `slots[${index}]`), `slots[${index}]`));
  const seen = new Set<string>();
  for (const slot of slots) {
    if (seen.has(slot.id)) {
      context.reader.fail("slots", `duplicate slot id ${slot.id}`);
    }
    seen.add(slot.id);
  }
  return slots;
}

function parseSlot(context: SlotContext, entry: JsonObject, path: string): Slot {
  const { reader } = context;
  reader.keys(entry, path, SLOT_KEYS);
  const kind = reader.member(entry["kind"], `${path}.kind`, ASSET_KINDS);
  const video = entry["video"] === undefined ? null : parseVideo(context, reader.object(entry["video"], `${path}.video`), `${path}.video`);
  if (VIDEO_KINDS.has(kind) !== (video !== null)) {
    reader.fail(`${path}.video`, `a ${kind} slot ${VIDEO_KINDS.has(kind) ? "needs" : "cannot have"} video traits`);
  }
  return {
    id: reader.text(entry["id"], `${path}.id`),
    store: reader.member(entry["store"], `${path}.store`, STORES),
    surface: reader.text(entry["surface"], `${path}.surface`),
    kind,
    width: reader.number(entry["width"], `${path}.width`, { min: 1, max: 8192 }),
    height: reader.number(entry["height"], `${path}.height`, { min: 1, max: 8192 }),
    maxCount: reader.number(entry["maxCount"], `${path}.maxCount`, { min: 1, max: 15 }),
    maxBytes: entry["maxBytes"] === undefined
      ? APPLE_MAX_BYTES
      : reader.number(entry["maxBytes"], `${path}.maxBytes`, { min: 1, max: 4_294_967_296 }),
    safeArea: entry["safeArea"] === undefined ? FULL_CANVAS : parseRect(reader, entry["safeArea"], `${path}.safeArea`),
    rules: reader.array(entry["rules"] ?? [], `${path}.rules`)
      .map((rule, index) => reader.member(rule, `${path}.rules[${index}]`, LAYOUT_RULES)),
    video,
    device: parseDeviceReference(context, entry, { path, kind }),
  };
}

function parseDeviceReference(context: SlotContext, entry: JsonObject, place: { path: string; kind: string }): Device | null {
  if (entry["device"] === undefined) {
    return null;
  }
  const id = context.reader.text(entry["device"], `${place.path}.device`);
  const device = context.devices.get(id);
  if (!device) {
    context.reader.fail(`${place.path}.device`, `unknown device ${id}`);
  }
  if (place.kind !== "screenshot") {
    context.reader.fail(`${place.path}.device`, `a ${place.kind} slot cannot reference a device`);
  }
  return device ?? null;
}

function parseVideo(context: SlotContext, entry: JsonObject, path: string): VideoTraits {
  const { reader, profiles } = context;
  reader.keys(entry, path, VIDEO_KEYS);
  const fps = reader.number(entry["fps"], `${path}.fps`, { min: 23, max: 60 });
  const acceptedFps = reader.array(entry["acceptedFps"], `${path}.acceptedFps`)
    .map((value, index) => reader.number(value, `${path}.acceptedFps[${index}]`, { min: 23, max: 60 }));
  if (!acceptedFps.includes(fps)) {
    reader.fail(`${path}.fps`, "must be one of acceptedFps");
  }
  const duration = reader.object(entry["duration"], `${path}.duration`);
  const min = reader.number(duration["min"], `${path}.duration.min`, { min: 5, max: 60 });
  const max = reader.number(duration["max"], `${path}.duration.max`, { min: 5, max: 60 });
  if (min > max) {
    reader.fail(`${path}.duration`, "min must not exceed max");
  }
  const profileId = reader.text(entry["codecProfile"], `${path}.codecProfile`);
  const codecProfile = profiles.get(profileId);
  if (!codecProfile) {
    reader.fail(`${path}.codecProfile`, `unknown codec profile ${profileId}`);
  }
  return {
    fps,
    acceptedFps,
    duration: { min, max },
    codecProfile: codecProfile ?? ({} as CodecProfile),
    audio: reader.member(entry["audio"], `${path}.audio`, AUDIO_POLICIES),
  };
}

function parseRect(reader: JsonReader, value: unknown, path: string): NormalizedRect {
  const entry = reader.object(value, path);
  const unit = { min: 0, max: 1 };
  const rect = {
    x: reader.number(entry["x"], `${path}.x`, unit),
    y: reader.number(entry["y"], `${path}.y`, unit),
    width: reader.number(entry["width"], `${path}.width`, unit),
    height: reader.number(entry["height"], `${path}.height`, unit),
  };
  if (rect.x + rect.width > 1.000001 || rect.y + rect.height > 1.000001 || rect.width === 0 || rect.height === 0) {
    reader.fail(path, "must be a non-empty rectangle inside the canvas");
  }
  return rect;
}
