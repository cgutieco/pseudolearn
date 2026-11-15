import { resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { describe, expect, it } from "vitest";
import { collectArchitectureViolations } from "../../scripts/check-architecture.mjs";
import { findComments } from "../../scripts/check-comments.mjs";
import { collectSizeViolations } from "../../scripts/check-size.mjs";

const fixtureRoot = resolve(fileURLToPath(new URL("../__fixtures__/", import.meta.url)));
const packageRoot = resolve(fileURLToPath(new URL("../../", import.meta.url)));

describe("package guards", () => {
  it("pass on the package as it stands", () => {
    expect(collectArchitectureViolations(packageRoot)).toEqual([]);
    expect(collectSizeViolations(packageRoot)).toEqual([]);
  });

  it("distinguish comment tokens from comment-like text", () => {
    expect(findComments("const url = 'https://example.test';")).toEqual([]);
    expect(findComments("const value = 1; // forbidden")).not.toEqual([]);
    expect(findComments("/* forbidden */ const value = 1;")).not.toEqual([]);
  });

  it("reject layer crossings, host imports outside adapters and undeclared folders", () => {
    const violations = collectArchitectureViolations(resolve(fixtureRoot, "bad-architecture"));
    expect(violations).toContain("src/catalog/reads_pipeline.ts: catalog cannot import pipeline");
    expect(violations).toContain("src/pipeline/writes_files.ts: pipeline cannot import node:fs");
    expect(violations).toContain("src/render: declared layer directory is missing");
    expect(violations).toContain("src/stray: source entry is not a declared layer");
  });

  it("reject files, functions, parameters, nesting and classes over the limits", () => {
    const violations = collectSizeViolations(resolve(fixtureRoot, "bad-size")).join("\n");
    expect(violations).toContain("lines exceeds 10");
    expect(violations).toContain("function exceeds 3 lines");
    expect(violations).toContain("parameter count exceeds 2");
    expect(violations).toContain("nesting exceeds 1");
    expect(violations).toContain("public methods exceed 1");
  });
});
