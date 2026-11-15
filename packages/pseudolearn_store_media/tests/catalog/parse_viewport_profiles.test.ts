import { describe, expect, it } from "vitest";
import { parseCatalog } from "../../src/catalog/parse_catalog.ts";
import { lexiconDocument, slot, slotsDocument } from "../support/catalog.ts";

type Mutable = Record<string, unknown>;

function errorsAfter(change: (header: Mutable) => void): readonly string[] {
  const document = slotsDocument();
  change((document["slots"] as Mutable[]).find((entry) => entry["id"] === "apple.header.video") as Mutable);
  const parsed = parseCatalog(document, lexiconDocument());
  return parsed.ok ? [] : parsed.errors.map((error) => `${error.path}: ${error.message}`);
}

function firstProfile(header: Mutable): Mutable {
  return (header["viewportProfiles"] as Mutable[])[0] as Mutable;
}

describe("viewport profiles", () => {
  it("gives the header the six device crops with their obstacles", () => {
    const profiles = slot("apple.header.video").viewportProfiles;
    expect(profiles.map((profile) => profile.name)).toEqual([
      "iPhone portrait, brand", "iPhone portrait, tagline", "iPhone Duo portrait",
      "iPhone Duo landscape", "iPad landscape", "iPad portrait",
    ]);
    expect(profiles[0]?.occlusions).toHaveLength(3);
  });

  it("keeps every obstacle inside its viewport", () => {
    for (const profile of slot("apple.header.video").viewportProfiles) {
      for (const occlusion of profile.occlusions) {
        expect(occlusion.x + occlusion.width, profile.name).toBeLessThanOrEqual(profile.viewport.width);
        expect(occlusion.y + occlusion.height, profile.name).toBeLessThanOrEqual(profile.viewport.height);
      }
    }
  });

  it("defaults to no profiles when a slot declares none", () => {
    expect(slot("apple.search.video").viewportProfiles).toEqual([]);
  });

});

describe("viewport profile rejections", () => {
  it("rejects an obstacle that leaves the viewport", () => {
    expect(errorsAfter((header) => {
      (firstProfile(header)["occlusions"] as Mutable[])[0] = { x: 300, y: 8, width: 106, height: 31 };
    })).toEqual(["slots[7].viewportProfiles[0].occlusions[0]: must be a non-empty rectangle inside the viewport"]);
  });

  it("rejects an empty obstacle and an unknown key", () => {
    expect(errorsAfter((header) => {
      const profile = firstProfile(header);
      (profile["occlusions"] as Mutable[])[1] = { x: 0, y: 0, width: 0, height: 4 };
      profile["notch"] = true;
    })).toEqual([
      "slots[7].viewportProfiles[0].notch: unknown key",
      "slots[7].viewportProfiles[0].occlusions[1]: must be a non-empty rectangle inside the viewport",
    ]);
  });

  it("rejects an empty viewport", () => {
    expect(errorsAfter((header) => {
      const profile = firstProfile(header);
      profile["viewport"] = { width: 0, height: 207 };
      profile["occlusions"] = [];
    })).toEqual(["slots[7].viewportProfiles[0].viewport.width: expected a number between 1 and 4096"]);
  });

  it("rejects profiles that are not a list", () => {
    expect(errorsAfter((header) => {
      header["viewportProfiles"] = { name: "phone" };
    })).toEqual(["slots[7].viewportProfiles: expected an array"]);
  });
});
