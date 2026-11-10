import type { ViewportProfile, ViewportRect } from "./catalog_types.ts";
import type { JsonReader } from "./json_reader.ts";

const PROFILE_KEYS = ["name", "viewport", "occlusions"];
const POINTS = { min: 0, max: 4096 };
const EPSILON = 1e-6;

export function parseViewportProfiles(reader: JsonReader, value: unknown, path: string): readonly ViewportProfile[] {
  if (value === undefined) {
    return [];
  }
  return reader.array(value, path).map((entry, index) => parseProfile(reader, entry, `${path}[${index}]`));
}

function parseProfile(reader: JsonReader, value: unknown, path: string): ViewportProfile {
  const entry = reader.object(value, path);
  reader.keys(entry, path, PROFILE_KEYS);
  const viewportEntry = reader.object(entry["viewport"], `${path}.viewport`);
  const viewport = {
    width: reader.number(viewportEntry["width"], `${path}.viewport.width`, { min: 1, max: POINTS.max }),
    height: reader.number(viewportEntry["height"], `${path}.viewport.height`, { min: 1, max: POINTS.max }),
  };
  const occlusions = reader.array(entry["occlusions"] ?? [], `${path}.occlusions`)
    .map((item, index) => parseOcclusion(reader, item, { path: `${path}.occlusions[${index}]`, viewport }));
  return { name: reader.text(entry["name"], `${path}.name`), viewport, occlusions };
}

type OcclusionPlace = { readonly path: string; readonly viewport: { readonly width: number; readonly height: number } };

function parseOcclusion(reader: JsonReader, value: unknown, place: OcclusionPlace): ViewportRect {
  const entry = reader.object(value, place.path);
  const rect = {
    x: reader.number(entry["x"], `${place.path}.x`, POINTS),
    y: reader.number(entry["y"], `${place.path}.y`, POINTS),
    width: reader.number(entry["width"], `${place.path}.width`, POINTS),
    height: reader.number(entry["height"], `${place.path}.height`, POINTS),
  };
  const outside = rect.x + rect.width > place.viewport.width + EPSILON || rect.y + rect.height > place.viewport.height + EPSILON;
  if (outside || rect.width === 0 || rect.height === 0) {
    reader.fail(place.path, "must be a non-empty rectangle inside the viewport");
  }
  return rect;
}
