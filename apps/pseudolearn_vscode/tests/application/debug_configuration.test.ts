import { describe, expect, it } from "vitest";
import { debugLaunch } from "../../src/application/debug_configuration";

describe("debugLaunch", () => {
  it("preserves a saved file and exact seed", () => {
    expect(debugLaunch({ program: "/p/a.pseudo", seed: "9223372036854775807" })).toEqual({
      ok: true, value: { program: "/p/a.pseudo", seed: "9223372036854775807", stopOnEntry: true },
    });
  });

  it("requires a project entry", () => {
    expect(debugLaunch({ project: "/p" })).toEqual({ ok: false, reason: "entry" });
  });

  it("rejects native debug and authority in launch data", () => {
    expect(debugLaunch({ program: "/p/a.pseudo", backend: "native" }).ok).toBe(false);
    expect(debugLaunch({ program: "/p/a.pseudo", grants: ["red"] }).ok).toBe(false);
  });

  it("rejects ambiguous targets and rounded seeds", () => {
    expect(debugLaunch({ program: "/a", project: "/p", entry: "a" }).ok).toBe(false);
    expect(debugLaunch({ program: "/a", seed: 9223372036854775807 }).ok).toBe(false);
  });
});
