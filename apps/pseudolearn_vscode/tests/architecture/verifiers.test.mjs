import { resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { describe, expect, it } from "vitest";
import { findComments } from "../../scripts/check-comments.mjs";
import { collectArchitectureViolations } from "../../scripts/check-architecture.mjs";
import { collectSizeViolations } from "../../scripts/check-size.mjs";
import { collectPackageViolations } from "../../scripts/check-package.mjs";
import { assertQualifiedTarget } from "../../scripts/package.mjs";

const fixtureRoot = resolve(fileURLToPath(new URL("../__fixtures__/", import.meta.url)));

describe("extension source guards", () => {
  it("distinguishes comment tokens from comment-like text", () => {
    expect(findComments("const url = 'https://example.test';")).toEqual([]);
    expect(findComments("const value = 1; // forbidden")).not.toEqual([]);
  });

  it("rejects forbidden imports and undeclared source folders", () => {
    const violations = collectArchitectureViolations(resolve(fixtureRoot, "bad-architecture"));
    expect(violations.some((value) => value.includes("cannot import application"))).toBe(true);
    expect(violations.some((value) => value.includes("declared layer directory is missing"))).toBe(true);
    expect(violations.some((value) => value.includes("not a declared layer"))).toBe(true);
  });

  it("rejects files and functions over configured limits", () => {
    const violations = collectSizeViolations(resolve(fixtureRoot, "bad-size"));
    expect(violations.some((value) => value.includes("lines exceeds"))).toBe(true);
    expect(violations.some((value) => value.includes("function exceeds"))).toBe(true);
  });

  it("rejects excluded sources and secret-bearing package resources", () => {
    const violations = collectPackageViolations(resolve(fixtureRoot, "bad-package"));
    expect(violations.some((value) => value.includes("excluded resource is included"))).toBe(true);
    expect(violations.some((value) => value.includes("secret-bearing"))).toBe(true);
  });

  it("accepts only the declared darwin arm64, Windows x64 and Linux x64 package targets", () => {
    const extensionRoot = resolve(fixtureRoot, "../..");
    expect(assertQualifiedTarget(extensionRoot, "darwin-arm64").target.vscodeTarget).toBe("darwin-arm64");
    expect(assertQualifiedTarget(extensionRoot, "win32-x64").target.vscodeTarget).toBe("win32-x64");
    expect(assertQualifiedTarget(extensionRoot, "linux-x64").target.vscodeTarget).toBe("linux-x64");
    expect(() => assertQualifiedTarget(extensionRoot, "linux-arm64")).toThrow("darwin-arm64");
    expect(() => assertQualifiedTarget(extensionRoot, "darwin-x64")).toThrow("win32-x64");
  });
});
