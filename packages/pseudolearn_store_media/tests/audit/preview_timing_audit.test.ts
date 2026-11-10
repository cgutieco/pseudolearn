import { describe, expect, it } from "vitest";
import { auditReadingTime, auditSceneSpans, readingSeconds, type SceneSpan } from "../../src/audit/preview_timing_audit.ts";

const spans: readonly SceneSpan[] = [
  { label: "run", startSeconds: 0, endSeconds: 6, dissolveSeconds: 0, trimEndSeconds: 6, plateSeconds: 8 },
  { label: "trace", startSeconds: 5.4, endSeconds: 12, dissolveSeconds: 0.6, trimEndSeconds: 7, plateSeconds: 7 },
];

describe("auditSceneSpans", () => {
  it("accepts dissolves within 0.4–1.5 s and scenes that hold alone for 2 s", () => {
    expect(auditSceneSpans(spans)).toEqual([]);
  });

  it("rejects a dissolve that is too quick or too slow", () => {
    const quick = [spans[0]!, { ...spans[1]!, dissolveSeconds: 0.2 }];
    const slow = [spans[0]!, { ...spans[1]!, dissolveSeconds: 2 }];
    expect(auditSceneSpans(quick).map((entry) => entry.rule)).toEqual(["MEDIA-TRANSITION"]);
    expect(auditSceneSpans(slow).map((entry) => entry.rule)).toEqual(["MEDIA-TRANSITION"]);
  });

  it("rejects a scene that is gone before it can be seen on its own", () => {
    const rapid = [{ ...spans[0]!, endSeconds: 2.5 }, { ...spans[1]!, startSeconds: 1.9 }];
    expect(auditSceneSpans(rapid)[0]?.message).toContain("holds alone for 1.90s");
  });

  it("rejects a trim past the end of the recorded plate", () => {
    expect(auditSceneSpans([{ ...spans[0]!, trimEndSeconds: 8.5 }]).map((entry) => entry.rule)).toEqual(["MEDIA-PLATE"]);
  });

  it("accepts an empty preview", () => {
    expect(auditSceneSpans([])).toEqual([]);
  });
});

describe("auditReadingTime", () => {
  const span = { text: "Tu programa *cobra vida.*", startSeconds: 1, endSeconds: 4, sceneStartSeconds: 0, sceneEndSeconds: 6 };

  it("asks for one second plus a third of a second per word, never under two seconds", () => {
    expect(readingSeconds("Tu programa *cobra vida.*")).toBeCloseTo(1 + 4 / 3);
    expect(readingSeconds("Hola")).toBe(2);
    expect(readingSeconds("")).toBe(2);
  });

  it("accepts text that stays long enough inside its scene", () => {
    expect(auditReadingTime([span])).toEqual([]);
  });

  it("rejects text that leaves too soon or outlives its scene", () => {
    expect(auditReadingTime([{ ...span, endSeconds: 2.5 }]).map((entry) => entry.rule)).toEqual(["TEXT-READ-TIME"]);
    expect(auditReadingTime([{ ...span, endSeconds: 6.5 }])[0]?.message).toBe("outlives the scene that shows it");
  });
});
