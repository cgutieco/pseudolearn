import { describe, expect, it } from "vitest";
import { parseCatalog } from "../../src/catalog/parse_catalog.ts";
import { lexiconDocument, realCatalog, slotsDocument } from "../support/catalog.ts";

type Mutable = Record<string, unknown>;

function errorsWithPreviewProfile(change: (profile: Mutable) => void): readonly string[] {
  const document = slotsDocument();
  const profiles = document["codecProfiles"] as Record<string, Mutable>;
  change(profiles["apple-preview"] as Mutable);
  const parsed = parseCatalog(document, lexiconDocument());
  return parsed.ok ? [] : parsed.errors.map((error) => `${error.path}: ${error.message}`);
}

describe("codec profiles", () => {
  it("holds app previews to a constant 11 Mbps inside the 10–12 Mbps that Apple targets", () => {
    const profile = realCatalog().slots.find((slot) => slot.id === "apple.iphone.app-preview")?.video?.codecProfile;
    expect(profile).toMatchObject({ rateControl: "cbr", minBitrateMbps: 10, bitrateMbps: 11, maxBitrateMbps: 12, level: "4.0" });
    expect(profile?.containers).toEqual(["mp4", "m4v", "mov"]);
  });

  it("lets creative profiles vary their bitrate without a floor", () => {
    const profile = realCatalog().slots.find((slot) => slot.id === "apple.header.video")?.video?.codecProfile;
    expect(profile).toMatchObject({ rateControl: "vbr", minBitrateMbps: null });
  });

  it("rejects a ceiling below the target and a floor above it", () => {
    expect(errorsWithPreviewProfile((profile) => {
      profile["maxBitrateMbps"] = 2;
    })).toContain("codecProfiles.apple-preview.bitrateMbps: must lie between minBitrateMbps and maxBitrateMbps");
    expect(errorsWithPreviewProfile((profile) => {
      profile["minBitrateMbps"] = 11.5;
    })).toContain("codecProfiles.apple-preview.bitrateMbps: must lie between minBitrateMbps and maxBitrateMbps");
  });

  it("rejects an unknown rate control and a container Apple does not accept", () => {
    const errors = errorsWithPreviewProfile((profile) => {
      profile["rateControl"] = "crf";
      profile["containers"] = ["mp4", "webm"];
    });
    expect(errors.some((error) => error.startsWith("codecProfiles.apple-preview.rateControl: expected one of"))).toBe(true);
    expect(errors.some((error) => error.startsWith("codecProfiles.apple-preview.containers[1]: expected one of"))).toBe(true);
  });
});
