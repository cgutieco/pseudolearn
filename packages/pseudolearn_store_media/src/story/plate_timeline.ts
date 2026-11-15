import type { Parsed } from "../catalog/catalog_types.ts";
import { JsonReader, type JsonObject } from "../catalog/json_reader.ts";

export const PLATE_EVENT_KINDS = ["statement", "diagram-node", "agent-message", "completion", "tap"] as const;
export type PlateEventKind = (typeof PLATE_EVENT_KINDS)[number];

export type FocusRect = { readonly key: string; readonly x: number; readonly y: number; readonly width: number; readonly height: number };

export type PlateFrame = { readonly index: number; readonly file: string; readonly focus: readonly FocusRect[] };

export type PlatePoint = { readonly x: number; readonly y: number };

export type PlateEvent = { readonly frame: number; readonly kind: PlateEventKind; readonly point: PlatePoint | null };

export type PlateTimeline = {
  readonly scene: string;
  readonly language: string;
  readonly fps: number;
  readonly pixelWidth: number;
  readonly pixelHeight: number;
  readonly frames: readonly PlateFrame[];
  readonly events: readonly PlateEvent[];
};

export function parsePlateTimeline(document: unknown): Parsed<PlateTimeline> {
  const reader = new JsonReader();
  const root = reader.object(document, "$");
  reader.keys(root, "$", ["scene", "language", "fps", "pixelWidth", "pixelHeight", "frames", "events"]);
  const timeline: PlateTimeline = {
    scene: reader.text(root["scene"], "scene"),
    language: reader.text(root["language"], "language"),
    fps: reader.number(root["fps"], "fps", { min: 1, max: 60 }),
    pixelWidth: reader.number(root["pixelWidth"], "pixelWidth", { min: 1, max: 8192 }),
    pixelHeight: reader.number(root["pixelHeight"], "pixelHeight", { min: 1, max: 8192 }),
    frames: reader.array(root["frames"], "frames").map((value, index) => parseFrame(reader, value, index)),
    events: reader.array(root["events"], "events").map((value, index) => parseEvent(reader, value, index)),
  };
  verifyOrder(reader, timeline);
  return reader.errors.length === 0 ? { ok: true, value: timeline } : { ok: false, errors: reader.errors };
}

function parseFrame(reader: JsonReader, value: unknown, index: number): PlateFrame {
  const entry = reader.object(value, `frames[${index}]`);
  return {
    index: reader.number(entry["index"], `frames[${index}].index`, { min: 0, max: 100_000 }),
    file: reader.text(entry["file"], `frames[${index}].file`),
    focus: reader.array(entry["focus"], `frames[${index}].focus`).map((rect, position) =>
      parseFocus(reader, reader.object(rect, `frames[${index}].focus[${position}]`), `frames[${index}].focus[${position}]`)),
  };
}

function parseFocus(reader: JsonReader, entry: JsonObject, path: string): FocusRect {
  const positive = { min: 0, max: 8192 };
  return {
    key: reader.text(entry["key"], `${path}.key`),
    x: reader.number(entry["x"], `${path}.x`, positive),
    y: reader.number(entry["y"], `${path}.y`, positive),
    width: reader.number(entry["width"], `${path}.width`, positive),
    height: reader.number(entry["height"], `${path}.height`, positive),
  };
}

function parseEvent(reader: JsonReader, value: unknown, index: number): PlateEvent {
  const path = `events[${index}]`;
  const entry = reader.object(value, path);
  const kind = reader.member(entry["kind"], `${path}.kind`, PLATE_EVENT_KINDS);
  const hasPoint = entry["x"] !== undefined || entry["y"] !== undefined;
  if ((kind === "tap") !== hasPoint) {
    reader.fail(path, "a tap carries the x and y of the touch, and only a tap does");
  }
  const pixels = { min: 0, max: 8192 };
  return {
    frame: reader.number(entry["frame"], `${path}.frame`, { min: 0, max: 100_000 }),
    kind,
    point: hasPoint ? { x: reader.number(entry["x"], `${path}.x`, pixels), y: reader.number(entry["y"], `${path}.y`, pixels) } : null,
  };
}

function verifyOrder(reader: JsonReader, timeline: PlateTimeline): void {
  timeline.frames.forEach((frame, position) => {
    if (frame.index !== position) {
      reader.fail(`frames[${position}].index`, "frames must be numbered from 0 without gaps");
    }
  });
  const last = timeline.frames.length;
  timeline.events.forEach((event, position) => {
    if (event.frame >= last) {
      reader.fail(`events[${position}].frame`, "event refers to a frame that does not exist");
    }
  });
}
