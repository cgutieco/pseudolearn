import { describe, expect, it } from "vitest";
import { buildRunArguments } from "../../src/application/run_arguments";
import type { RunSettings } from "../../src/contracts/editor_run";

const settings: RunSettings = { executable: "/bin/pseudo", language: "en", profile: "es", strictness: "strict" };

describe("buildRunArguments", () => {
  it("builds a file run without a shell", () => {
    expect(buildRunArguments({ kind: "file", path: "/a b/$(x);p.pseudo" }, settings)).toEqual([
      "run", "--editor", "--language", "en", "--strictness", "strict", "--profile", "es", "/a b/$(x);p.pseudo",
    ]);
  });

  it("builds a project run with the chosen entry", () => {
    expect(buildRunArguments({ kind: "project", directory: "/p q", entry: "app/main" }, settings)).toEqual([
      "run", "--editor", "--language", "en", "--strictness", "strict", "--project", "/p q", "--entry", "app/main",
    ]);
  });
});
