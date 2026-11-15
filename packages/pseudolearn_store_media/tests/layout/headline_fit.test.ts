import { describe, expect, it } from "vitest";
import { fitHeadline, type HeadlineFitRequest } from "../../src/layout/headline_fit.ts";

const monospace = (text: string, size: number): number => text.length * size * 0.5;

function request(overrides: Partial<HeadlineFitRequest>): HeadlineFitRequest {
  return { lines: ["abcd"], boxWidth: 400, boxHeight: 400, maximumFontSize: 100, minimumFontSize: 20, lineHeight: 1, measure: monospace, ...overrides };
}

describe("fitHeadline", () => {
  it("keeps the maximum size when the headline fits", () => {
    expect(fitHeadline(request({}))).toEqual({ fits: true, fontSize: 100, width: 200, height: 100 });
  });

  it("shrinks until the widest line fits", () => {
    const fit = fitHeadline(request({ lines: ["abcdefghijklmnop", "ab"] }));
    expect(fit).toMatchObject({ fits: true, fontSize: 50 });
  });

  it("shrinks until every line fits in the height", () => {
    const fit = fitHeadline(request({ lines: ["a", "b", "c"], boxHeight: 150 }));
    expect(fit).toMatchObject({ fits: true, fontSize: 50 });
  });

  it("tries the exact minimum when it is fractional", () => {
    const fit = fitHeadline(request({ lines: ["abcdefghijklmnop"], boxWidth: 165, maximumFontSize: 30, minimumFontSize: 20.5 }));
    expect(fit).toMatchObject({ fits: true, fontSize: 20.5 });
  });
});

describe("fitHeadline rejections", () => {
  it("reports the lines that stay too wide at the minimum size", () => {
    const fit = fitHeadline(request({ lines: ["a".repeat(100), "ok"] }));
    expect(fit).toEqual({ fits: false, fontSize: 20, overflowingLines: ["a".repeat(100)] });
  });

  it("reports every line when the block is too tall at the minimum size", () => {
    const fit = fitHeadline(request({ lines: ["a", "b", "c"], boxHeight: 10 }));
    expect(fit).toEqual({ fits: false, fontSize: 20, overflowingLines: ["a", "b", "c"] });
  });
});
