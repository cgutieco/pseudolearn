import { describe, expect, it } from "vitest";
import { DebugReferences, maximumReferences } from "../../src/application/debug_references";

describe("DebugReferences", () => {
  it("returns frames and variables only for the generation that created them", () => {
    const references = new DebugReferences();
    const frame = references.allocate({ kind: "frame", task: "1", position: "0", generation: "3" });
    const values = references.allocate({ kind: "variables", task: "1", target: "0", query: "frame_variables", generation: "3" });
    expect(references.frame(frame, "3").position).toBe("0");
    expect(references.variables(values, "3").query).toBe("frame_variables");
    expect(() => references.frame(frame, "4")).toThrow("stale or foreign frame reference");
    expect(() => references.variables(frame, "3")).toThrow("stale or foreign variable reference");
    expect(() => references.frame("1", "3")).toThrow("invalid frame reference");
    references.clear();
    expect(() => references.frame(frame, "3")).toThrow("stale");
  });

  it("stops allocating at the table limit", () => {
    const references = new DebugReferences();
    for (let index = 0; index < maximumReferences; index += 1) {
      references.allocate({ kind: "frame", task: "0", position: "0", generation: "0" });
    }
    expect(() => references.allocate({ kind: "frame", task: "0", position: "0", generation: "0" })).toThrow("limit exceeded");
  });
});
