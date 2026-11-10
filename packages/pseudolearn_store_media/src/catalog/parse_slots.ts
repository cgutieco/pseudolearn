import {
  ASSET_KINDS,
  AUDIO_POLICIES,
  LABEL_KINDS,
  LAYOUT_RULES,
  STORES,
  type CodecProfile,
  type Device,
  type LabelKind,
  type LabelLimits,
  type NormalizedRect,
  type Slot,
  type VideoTraits,
} from "./catalog_types.ts";
import type { JsonObject, JsonReader } from "./json_reader.ts";
import { parseViewportProfiles } from "./parse_viewport_profiles.ts";

const SLOT_KEYS = ["id", "store", "surface", "kind", "width", "height", "maxCount", "maxBytes", "safeArea", "rules", "labelLimits",
  "viewportProfiles", "video", "device"];
const VIDEO_KEYS = ["fps", "acceptedFps", "duration", "codecProfile", "audio"];
const APPLE_MAX_BYTES = 524_288_000;
const FULL_CANVAS: NormalizedRect = { x: 0, y: 0, width: 1, height: 1 };
const VIDEO_KINDS = new Set(["app-preview", "header-video", "search-video", "trailer"]);
const DEVICE_KINDS = new Set(["screenshot", "app-preview"]);
const LABEL_RANGE = { min: 1, max: 10_000 };
const TWO_THIRDS = 2 / 3;
const RECT_TOLERANCE = 1e-4;

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
  const slot: Slot = {
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
    labelLimits: parseLabelLimits(reader, entry["labelLimits"], `${path}.labelLimits`),
    viewportProfiles: parseViewportProfiles(reader, entry["viewportProfiles"], `${path}.viewportProfiles`),
    video,
    device: parseDeviceReference(context, entry, { path, kind }),
  };
  verifyPreviewPlate(reader, slot, path);
  verifyTopTwoThirds(reader, slot, path);
  return slot;
}

function parseLabelLimits(reader: JsonReader, value: unknown, path: string): LabelLimits {
  if (value === undefined) {
    return {};
  }
  const entry = reader.object(value, path);
  reader.keys(entry, path, LABEL_KINDS);
  const limits: Partial<Record<LabelKind, number>> = {};
  for (const kind of LABEL_KINDS) {
    if (entry[kind] !== undefined) {
      limits[kind] = reader.number(entry[kind], `${path}.${kind}`, LABEL_RANGE);
    }
  }
  return limits;
}

function verifyTopTwoThirds(reader: JsonReader, slot: Slot, path: string): void {
  const bottom = slot.safeArea.y + slot.safeArea.height;
  if (slot.rules.includes("critical-top-two-thirds") && bottom > TWO_THIRDS + RECT_TOLERANCE) {
    reader.fail(`${path}.safeArea`, "a critical-top-two-thirds slot keeps its safe area inside the top two thirds");
  }
}

function verifyPreviewPlate(reader: JsonReader, slot: Slot, path: string): void {
  if (slot.kind !== "app-preview") {
    return;
  }
  const device = slot.device;
  if (!device) {
    reader.fail(`${path}.device`, "an app-preview slot records its plates on a device");
    return;
  }
  if (device.logicalWidth * device.plateScale !== slot.width || device.logicalHeight * device.plateScale !== slot.height) {
    reader.fail(`${path}.device`, `${device.id} records ${device.logicalWidth * device.plateScale}×${device.logicalHeight * device.plateScale} px, not the native ${slot.width}×${slot.height}`);
  }
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
  if (!DEVICE_KINDS.has(place.kind)) {
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
