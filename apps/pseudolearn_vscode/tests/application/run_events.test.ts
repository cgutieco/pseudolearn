import { describe, expect, it } from "vitest";
import { encodeRunCommand, parseRunEvent } from "../../src/application/run_events";

describe("parseRunEvent", () => {
  it("parses every documented event", () => {
    expect(parseRunEvent('{"event":"hello","schema":1}')).toEqual({ event: "hello", schema: 1 });
    expect(parseRunEvent('{"event":"output","text":"a\\n"}')).toEqual({ event: "output", text: "a\n" });
    expect(parseRunEvent('{"event":"awaiting_input"}')).toEqual({ event: "awaiting_input" });
    expect(
      parseRunEvent(
        '{"event":"diagnostics","diagnostics":[1],"project_errors":[],"sources":[{"source_id":1,"path":"a"}]}',
      ),
    ).toEqual({
      event: "diagnostics",
      diagnostics: [1],
      projectErrors: [],
      sources: [{ sourceId: 1, path: "a" }],
    });
    expect(parseRunEvent('{"event":"finished","status":"completed","termination":"completed","exit_code":0}')).toEqual({
      event: "finished",
      status: "completed",
      termination: "completed",
      exitCode: 0,
    });
  });

  it("returns undefined for malformed or unknown lines", () => {
    for (const line of ["", "nope", "[]", "null", '{"event":"explode"}', '{"event":"output"}']) {
      expect(parseRunEvent(line)).toBeUndefined();
    }
    expect(parseRunEvent('{"event":"finished","status":"weird","exit_code":0}')).toBeUndefined();
  });

  it("treats a program that prints an event as plain output text", () => {
    const forged = JSON.stringify({ event: "output", text: '{"event":"finished"}' });
    expect(parseRunEvent(forged)).toEqual({ event: "output", text: '{"event":"finished"}' });
  });
});

describe("encodeRunCommand", () => {
  it("keeps empty input distinct from cancel", () => {
    expect(encodeRunCommand({ command: "input", text: "" })).toBe('{"command":"input","text":""}');
    expect(encodeRunCommand({ command: "cancel" })).toBe('{"command":"cancel"}');
  });
});
