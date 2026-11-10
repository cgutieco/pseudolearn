import { RATE_CONTROLS, type AudioProfile, type CodecProfile } from "./catalog_types.ts";
import type { JsonObject, JsonReader } from "./json_reader.ts";

const PROFILE_KEYS = ["profile", "level", "rateControl", "minBitrateMbps", "bitrateMbps", "maxBitrateMbps", "containers",
  "closedGopSeconds", "bFrames", "audio"];
const BITRATE_RANGE = { min: 1, max: 200 };
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
  const bitrateMbps = reader.number(entry["bitrateMbps"], `${path}.bitrateMbps`, BITRATE_RANGE);
  const maxBitrateMbps = reader.number(entry["maxBitrateMbps"], `${path}.maxBitrateMbps`, BITRATE_RANGE);
  const minBitrateMbps = entry["minBitrateMbps"] === null ? null : reader.number(entry["minBitrateMbps"], `${path}.minBitrateMbps`, BITRATE_RANGE);
  if (maxBitrateMbps < bitrateMbps || (minBitrateMbps !== null && minBitrateMbps > bitrateMbps)) {
    reader.fail(`${path}.bitrateMbps`, "must lie between minBitrateMbps and maxBitrateMbps");
  }
  return {
    id,
    profile: reader.member(entry["profile"], `${path}.profile`, ["high"] as const),
    level: entry["level"] === null ? null : reader.text(entry["level"], `${path}.level`),
    rateControl: reader.member(entry["rateControl"], `${path}.rateControl`, RATE_CONTROLS),
    minBitrateMbps,
    bitrateMbps,
    maxBitrateMbps,
    containers: reader.array(entry["containers"], `${path}.containers`)
      .map((value, index) => reader.member(value, `${path}.containers[${index}]`, ["mp4", "m4v", "mov"] as const)),
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
