import type { AudioProfile, CodecProfile } from "./catalog_types.ts";
import type { JsonObject, JsonReader } from "./json_reader.ts";

const PROFILE_KEYS = ["profile", "level", "bitrateMbps", "maxBitrateMbps", "closedGopSeconds", "bFrames", "audio"];
const AUDIO_KEYS = ["codec", "bitrateKbps", "sampleRate", "channels"];

export function parseCodecProfiles(reader: JsonReader, document: JsonObject): ReadonlyMap<string, CodecProfile> {
  const profiles = new Map<string, CodecProfile>();
  const entries = reader.object(document["codecProfiles"], "codecProfiles");
  for (const [id, value] of Object.entries(entries)) {
    profiles.set(id, parseProfile(reader, id, reader.object(value, `codecProfiles.${id}`)));
  }
  return profiles;
}

function parseProfile(reader: JsonReader, id: string, entry: JsonObject): CodecProfile {
  const path = `codecProfiles.${id}`;
  reader.keys(entry, path, PROFILE_KEYS);
  const bitrateMbps = reader.number(entry["bitrateMbps"], `${path}.bitrateMbps`, { min: 1, max: 200 });
  const maxBitrateMbps = reader.number(entry["maxBitrateMbps"], `${path}.maxBitrateMbps`, { min: 1, max: 200 });
  if (maxBitrateMbps < bitrateMbps) {
    reader.fail(`${path}.maxBitrateMbps`, "must not be lower than bitrateMbps");
  }
  return {
    id,
    profile: reader.member(entry["profile"], `${path}.profile`, ["high"] as const),
    level: entry["level"] === null ? null : reader.text(entry["level"], `${path}.level`),
    bitrateMbps,
    maxBitrateMbps,
    closedGopSeconds: nullableNumber(reader, entry["closedGopSeconds"], `${path}.closedGopSeconds`),
    bFrames: nullableNumber(reader, entry["bFrames"], `${path}.bFrames`),
    audio: parseAudio(reader, reader.object(entry["audio"], `${path}.audio`), `${path}.audio`),
  };
}

function parseAudio(reader: JsonReader, entry: JsonObject, path: string): AudioProfile {
  reader.keys(entry, path, AUDIO_KEYS);
  const sampleRate = reader.number(entry["sampleRate"], `${path}.sampleRate`, { min: 44100, max: 48000 });
  if (sampleRate !== 44100 && sampleRate !== 48000) {
    reader.fail(`${path}.sampleRate`, "expected 44100 or 48000");
  }
  return {
    codec: reader.member(entry["codec"], `${path}.codec`, ["aac"] as const),
    bitrateKbps: reader.number(entry["bitrateKbps"], `${path}.bitrateKbps`, { min: 64, max: 512 }),
    sampleRate,
    channels: reader.number(entry["channels"], `${path}.channels`, { min: 2, max: 2 }),
  };
}

function nullableNumber(reader: JsonReader, value: unknown, path: string): number | null {
  if (value === null) {
    return null;
  }
  return reader.number(value, path, { min: 0, max: 60 });
}
