import { describe, expect, it } from "vitest";
import { buildSafeAreaReview } from "../../src/compose/safe_area_review.ts";
import { slot } from "../support/catalog.ts";

const header = slot("apple.header.video");

describe("buildSafeAreaReview", () => {
  it("places each sampled frame in every crop with the zone and the obstacles", () => {
    const review = buildSafeAreaReview({ slot: header, samples: [{ timeSeconds: 0, image: "frame-0.png" }, { timeSeconds: 5, image: "frame-150.png" }] });
    expect(review.html.match(/<img src="frame-0\.png"/gu)).toHaveLength(7);
    expect(review.html.match(/<img src="frame-150\.png"/gu)).toHaveLength(7);
    expect(review.html.match(/class="safe"/gu)).toHaveLength(14);
    expect(review.html.match(/class="occlusion"/gu)).toHaveLength(2 * 16);
    expect(review.html).toContain("5.00 s · iPad landscape");
  });

  it("is a one-second still that carries no store text", () => {
    const review = buildSafeAreaReview({ slot: header, samples: [] });
    expect(review.durationSeconds).toBe(1);
    expect(review.texts).toEqual([]);
    expect(review.layout).toEqual([]);
  });

  it("escapes the image names it receives", () => {
    const review = buildSafeAreaReview({ slot: header, samples: [{ timeSeconds: 0, image: "a\"b.png" }] });
    expect(review.html).toContain('src="a&quot;b.png"');
  });
});
