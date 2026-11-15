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

  it("rejects every retired concession key with an explicit authority error", () => {
    for (const key of ["grants", "permissions", "origins", "filesRoot", "env", "serverPath"]) {
      expect(debugLaunch({ program: "/p/a.pseudo", [key]: "x" })).toEqual({ ok: false, reason: "authority" });
    }
  });

  it("carries program arguments and working directory", () => {
    expect(debugLaunch({ program: "/p/a.pseudo", args: ["", "λ"], cwd: "/work dir" })).toEqual({
      ok: true, value: { program: "/p/a.pseudo", args: ["", "λ"], cwd: "/work dir", stopOnEntry: true },
    });
  });

  it("rejects non-string arguments and an empty working directory", () => {
    expect(debugLaunch({ program: "/p/a.pseudo", args: [1] })).toEqual({ ok: false, reason: "options" });
    expect(debugLaunch({ program: "/p/a.pseudo", args: "x" })).toEqual({ ok: false, reason: "options" });
    expect(debugLaunch({ program: "/p/a.pseudo", cwd: "" })).toEqual({ ok: false, reason: "options" });
  });

  it("rejects ambiguous targets and rounded seeds", () => {
    expect(debugLaunch({ program: "/a", project: "/p", entry: "a" }).ok).toBe(false);
    expect(debugLaunch({ program: "/a", seed: 9223372036854775807 }).ok).toBe(false);
  });
});
