import { describe, expect, it } from "vitest";
import { parseCatalog } from "../../src/catalog/parse_catalog.ts";
import { lexiconDocument, realCatalog, slotsDocument } from "../support/catalog.ts";

type Mutable = Record<string, unknown>;

function errorsWithProfile(id: string, change: (profile: Mutable) => void): readonly string[] {
  const document = slotsDocument();
  const profiles = document["codecProfiles"] as Record<string, Mutable>;
  change(profiles[id] as Mutable);
  const parsed = parseCatalog(document, lexiconDocument());
  return parsed.ok ? [] : parsed.errors.map((error) => `${error.path}: ${error.message}`);
}

const profileOf = (slotId: string) => realCatalog().slots.find((slot) => slot.id === slotId)?.video?.codecProfile;

describe("codec profiles", () => {
  it("lets creative profiles vary their bitrate without a floor and keep edit lists", () => {
    expect(profileOf("apple.header.video")).toMatchObject({ rateControl: "vbr", minBitrateMbps: null, editLists: "allowed" });
    expect(profileOf("apple.header.video")?.containers).toEqual(["mp4", "m4v", "mov"]);
    expect(profileOf("apple.header.video")?.audio.encoder).toBe("native");
  });

  it("encodes the Microsoft trailer at a constant 50 Mbps with a closed half-second GOP and no edit lists", () => {
    expect(profileOf("microsoft.trailer")).toMatchObject({ rateControl: "cbr", minBitrateMbps: 45, bitrateMbps: 50, maxBitrateMbps: 55,
      closedGopSeconds: 0.5, bFrames: 2, editLists: "forbidden" });
    expect(profileOf("microsoft.trailer")?.audio).toEqual({ codec: "aac", encoder: "audiotoolbox", bitrateKbps: 320, sampleRate: 48000, channels: 2 });
  });
});

describe("codec profile rejections", () => {
  it("rejects an unknown AAC encoder, an unknown edit-list policy and a missing one", () => {
    expect(errorsWithProfile("apple-creative", (profile) => {
      (profile["audio"] as Mutable)["encoder"] = "fdk";
    }).some((error) => error.startsWith("codecProfiles.apple-creative.audio.encoder: expected one of"))).toBe(true);
    expect(errorsWithProfile("apple-creative", (profile) => {
      profile["editLists"] = "sometimes";
    }).some((error) => error.startsWith("codecProfiles.apple-creative.editLists: expected one of"))).toBe(true);
    expect(errorsWithProfile("apple-creative", (profile) => {
      delete profile["editLists"];
    }).some((error) => error.startsWith("codecProfiles.apple-creative.editLists:"))).toBe(true);
  });

  it("rejects a ceiling below the target and a floor above it", () => {
    expect(errorsWithProfile("microsoft-trailer", (profile) => {
      profile["maxBitrateMbps"] = 2;
    })).toContain("codecProfiles.microsoft-trailer.bitrateMbps: must lie between minBitrateMbps and maxBitrateMbps");
    expect(errorsWithProfile("microsoft-trailer", (profile) => {
      profile["minBitrateMbps"] = 51;
    })).toContain("codecProfiles.microsoft-trailer.bitrateMbps: must lie between minBitrateMbps and maxBitrateMbps");
  });

  it("rejects an unknown rate control, a container no store accepts and a level the catalog no longer knows", () => {
    const errors = errorsWithProfile("apple-creative", (profile) => {
      profile["rateControl"] = "crf";
      profile["containers"] = ["mp4", "webm"];
      profile["level"] = "4.0";
    });
    expect(errors.some((error) => error.startsWith("codecProfiles.apple-creative.rateControl: expected one of"))).toBe(true);
    expect(errors.some((error) => error.startsWith("codecProfiles.apple-creative.containers[1]: expected one of"))).toBe(true);
    expect(errors).toContain("codecProfiles.apple-creative.level: unknown key");
  });
});
