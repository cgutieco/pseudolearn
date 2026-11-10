import { describe, expect, it } from "vitest";
import { auditPoster, posterTextPixels, type PosterRequest } from "../../src/audit/poster_audit.ts";

const poster: PosterRequest = {
  target: "overview",
  posterSeconds: 5,
  durationSeconds: 24,
  fps: 30,
  transitions: [{ startSeconds: 7.4, endSeconds: 8 }],
  texts: [{ text: "Tu programa cobra vida", fontSize: 72 }],
  canvasLongSide: 1920,
};

describe("auditPoster", () => {
  it("accepts a frame outside every dissolve whose text survives the 600 px reduction", () => {
    expect(auditPoster(poster)).toEqual([]);
    expect(posterTextPixels(72, 1920)).toBeCloseTo(22.5);
  });

  it("rejects a poster before the start, on or after the last frame, and inside a dissolve", () => {
    expect(auditPoster({ ...poster, posterSeconds: -0.1 }).map((entry) => entry.rule)).toEqual(["MEDIA-POSTER"]);
    expect(auditPoster({ ...poster, posterSeconds: 24 })).toHaveLength(1);
    expect(auditPoster({ ...poster, posterSeconds: 24 - 1 / 30 })).toEqual([]);
    expect(auditPoster({ ...poster, posterSeconds: 7.5 })[0]?.message).toContain("inside a dissolve");
  });

  it("rejects text that would be under 11 px at 600 px and accepts it exactly at the edge", () => {
    expect(auditPoster({ ...poster, texts: [{ text: "small", fontSize: 32 }] })[0]).toMatchObject({ rule: "MEDIA-POSTER", target: "small" });
    expect(auditPoster({ ...poster, texts: [{ text: "edge", fontSize: 35.2 }] })).toEqual([]);
  });

  it("accepts a poster without text", () => {
    expect(auditPoster({ ...poster, texts: [] })).toEqual([]);
  });
});
