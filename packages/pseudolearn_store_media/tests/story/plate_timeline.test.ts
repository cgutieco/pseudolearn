import { describe, expect, it } from "vitest";
import { parsePlateTimeline } from "../../src/story/plate_timeline.ts";

function timeline(overrides: Record<string, unknown> = {}): Record<string, unknown> {
  return {
    scene: "editor",
    language: "es",
    fps: 30,
    pixelWidth: 886,
    pixelHeight: 1920,
    frames: [
      { index: 0, file: "frame-0000.png", focus: [{ key: "line", x: 10, y: 20, width: 300, height: 24 }] },
      { index: 1, file: "frame-0001.png", focus: [] },
      { index: 2, file: "frame-0002.png", focus: [] },
    ],
    events: [{ frame: 0, kind: "statement" }, { frame: 2, kind: "completion" }],
    ...overrides,
  };
}

describe("parsePlateTimeline", () => {
  it("reads the frames, focus rectangles and events the app exports", () => {
    const parsed = parsePlateTimeline(timeline());
    expect(parsed.ok).toBe(true);
    if (parsed.ok) {
      expect(parsed.value.frames[0]?.focus[0]?.key).toBe("line");
      expect(parsed.value.events).toHaveLength(2);
    }
  });

  it("rejects gaps in the numbering and events beyond the last frame", () => {
    const parsed = parsePlateTimeline(timeline({
      frames: [{ index: 0, file: "a.png", focus: [] }, { index: 2, file: "b.png", focus: [] }],
      events: [{ frame: 5, kind: "statement" }],
    }));
    expect(parsed.ok).toBe(false);
    if (!parsed.ok) {
      expect(parsed.errors.map((error) => error.message)).toEqual([
        "frames must be numbered from 0 without gaps",
        "event refers to a frame that does not exist",
      ]);
    }
  });

  it("rejects unknown event kinds and keys", () => {
    const parsed = parsePlateTimeline(timeline({ events: [{ frame: 0, kind: "explosion" }], extra: true }));
    expect(parsed.ok).toBe(false);
  });

  it("reads the point of a tap and rejects a tap without one or a point on another kind", () => {
    const tapped = parsePlateTimeline(timeline({ events: [{ frame: 1, kind: "tap", x: 10, y: 20 }] }));
    expect(tapped.ok && tapped.value.events[0]?.point).toEqual({ x: 10, y: 20 });
    expect(parsePlateTimeline(timeline({ events: [{ frame: 1, kind: "tap" }] })).ok).toBe(false);
    expect(parsePlateTimeline(timeline({ events: [{ frame: 1, kind: "statement", x: 1, y: 1 }] })).ok).toBe(false);
  });

  it("accepts a timeline with no events", () => {
    expect(parsePlateTimeline(timeline({ events: [] })).ok).toBe(true);
  });
});
