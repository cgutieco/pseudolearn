import { describe, expect, it } from "vitest";
import { summarize, validatePhysical } from "../../scripts/lib/web-measurements.mjs";

describe("Web measurement analysis", () => {
  it("rejects incorrect outputs, units and mixed builds", () => {
    const row = { process: 0, iteration: 0, target: "worker", workload: "integer", milliseconds: 1, unit: "ms", valid: true, build: "a", output: "42\n", expected: "42\n" };
    expect(() => summarize([{ ...row, output: "wrong" }])).toThrow();
    expect(() => summarize([{ ...row, unit: "s" }])).toThrow();
    expect(() => summarize([row, { ...row, process: 1, build: "b" }])).toThrow();
    expect(() => summarize([row])).toThrow();
  });
  it("rejects synthetic physical evidence and missing cycles", () => {
    expect(() => validatePhysical([{ physical: false }], { combinations: [] })).toThrow();
    expect(() => validatePhysical([], { combinations: [{ id: "phone" }], cycles: 20 })).toThrow();
  });
});
