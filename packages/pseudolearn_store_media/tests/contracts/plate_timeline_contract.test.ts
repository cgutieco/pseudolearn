import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { describe, expect, it } from "vitest";
import { parsePlateTimeline } from "../../src/story/plate_timeline.ts";

const fixture = fileURLToPath(new URL("./plate-timeline.json", import.meta.url));

describe("plate timeline contract with the app", () => {
  it("parses the document the app's exporter writes", () => {
    const parsed = parsePlateTimeline(JSON.parse(readFileSync(fixture, "utf8")));
    expect(parsed.ok).toBe(true);
    if (parsed.ok) {
      expect(parsed.value.frames[0]?.focus[0]).toEqual({ key: "tabs", x: 0, y: 96, width: 886, height: 88 });
      expect(parsed.value.events.map((event) => event.kind)).toEqual(["statement", "completion"]);
    }
  });
});
