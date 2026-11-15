import { describe, expect, it } from "vitest";
import { parseThermostatStory, traceEndSeconds } from "../../src/story/thermostat_story.ts";
import { shippedLensStory } from "../support/lens.ts";
import { guidedDemoTrace, shippedThermostat, thermostatDocument } from "../support/thermostat.ts";

function errorsOf(change: (document: Record<string, unknown>) => void): readonly string[] {
  const document = structuredClone(thermostatDocument());
  change(document);
  const parsed = parseThermostatStory(document);
  return parsed.ok ? [] : parsed.errors.map((error) => `${error.path}: ${error.message}`);
}

describe("the shipped thermostat trailer", () => {
  it("replays exactly what the guided demo program does", () => {
    expect(shippedThermostat().trace).toEqual(guidedDemoTrace());
  });

  it("shows the same program the app ships, line by line, in both languages", () => {
    const story = shippedThermostat();
    const lens = shippedLensStory();
    for (const language of ["es", "en"] as const) {
      expect(story.program[language].lines.map((line) => line.trim())).toEqual(lens.statements[language].map((statement) => statement.text));
    }
  });

  it("leaves the interface tail and the lockup after the trace and inside 60 seconds", () => {
    const story = shippedThermostat();
    expect(traceEndSeconds(story)).toBeCloseTo(17.2, 6);
    expect(story.interface.startSeconds).toBeGreaterThan(traceEndSeconds(story));
    expect(story.durationSeconds).toBeLessThanOrEqual(60);
  });
});

describe("parseThermostatStory rejections", () => {
  it("rejects a step on a line the program does not have and an output it does not write", () => {
    expect(errorsOf((document) => {
      (document["trace"] as Record<string, unknown>[])[0]!["line"] = 40;
    })).toContain("trace[0]: does not fit the es program");
    expect(errorsOf((document) => {
      (document["trace"] as Record<string, unknown>[])[5]!["output"] = 7;
    })).toContain("trace[5].output: has no es output 7");
  });

  it("rejects languages that do not translate the same program", () => {
    expect(errorsOf((document) => {
      const program = document["program"] as Record<string, Record<string, unknown[]>>;
      program["en"]!["lines"] = program["en"]!["lines"]!.slice(1);
    })).toContain("program: every language must translate the same lines, variables and outputs");
  });

  it("rejects a tail that overlaps the trace and a thumbnail outside the run", () => {
    expect(errorsOf((document) => {
      (document["interface"] as Record<string, unknown>)["startSeconds"] = 10;
    })).toEqual(["$: the trace, the interface tail and the lockup must follow each other inside the trailer"]);
    expect(errorsOf((document) => {
      document["thumbnailSeconds"] = 0.5;
    })).toEqual(["thumbnailSeconds: the thumbnail must show the program running"]);
  });

  it("rejects an empty trace", () => {
    expect(errorsOf((document) => {
      document["trace"] = [];
    })).toContain("trace: the trailer needs at least one step");
  });
});
