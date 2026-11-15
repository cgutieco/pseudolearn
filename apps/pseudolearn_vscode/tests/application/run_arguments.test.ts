import { describe, expect, it } from "vitest";
import { buildRunArguments } from "../../src/application/run_arguments";
import type { RunSettings } from "../../src/contracts/editor_run";

const settings: RunSettings = { executable: "/bin/pseudo", language: "en", profile: "es" };

describe("buildRunArguments", () => {
  it("builds a file run without a shell", () => {
    expect(buildRunArguments({ kind: "file", path: "/a b/$(x);p.pseudo" }, settings)).toEqual([
      "run", "--editor", "--language", "en", "--profile", "es", "/a b/$(x);p.pseudo",
    ]);
  });

  it("builds a project run with the chosen entry", () => {
    expect(buildRunArguments({ kind: "project", directory: "/p q", entry: "app/main" }, settings)).toEqual([
      "run", "--editor", "--language", "en", "--project", "/p q", "--entry", "app/main",
    ]);
  });

  it("passes program arguments after the separator without interpreting them", () => {
    const withArguments: RunSettings = { ...settings, args: ["", "λ x", "--seed"] };
    expect(buildRunArguments({ kind: "file", path: "/p.pseudo" }, withArguments)).toEqual([
      "run", "--editor", "--language", "en", "--profile", "es", "/p.pseudo", "--", "", "λ x", "--seed",
    ]);
  });

  it("emits no separator when there are no program arguments", () => {
    expect(buildRunArguments({ kind: "file", path: "/p.pseudo" }, { ...settings, args: [] })).not.toContain("--");
  });
});
