import { describe, expect, it } from "vitest";
import { containsUri, authorizeFile } from "../../src/application/uri_authority";

describe("URI authority", () => {
  it("accepts components with escaped Unicode and preserves authority", () => {
    expect(containsUri("memfs://host/ra%C3%ADz", "memfs://host/ra%C3%ADz/sub/a.pseudo")).toBe(true);
    expect(containsUri("memfs://host/root", "memfs://other/root/a")).toBe(false);
  });

  it("rejects sibling prefixes, traversal and encoded separators", () => {
    expect(containsUri("memfs://host/root", "memfs://host/root-two/a")).toBe(false);
    expect(containsUri("memfs://host/root", "memfs://host/root/%2E%2E/a")).toBe(false);
    expect(containsUri("memfs://host/root", "memfs://host/root/a%2Fb")).toBe(false);
  });

  it("requires a separate grant and provider confinement", () => {
    const grant = { root: "memfs://host/root", writable: false, confined: true };
    expect(authorizeFile(grant, "memfs://host/root/a", false)).toBe(true);
    expect(authorizeFile(grant, "memfs://host/root/a", true)).toBe(false);
    expect(authorizeFile({ ...grant, confined: false }, "memfs://host/root/a", false)).toBe(false);
    expect(authorizeFile(undefined, "memfs://host/root/a", false)).toBe(false);
  });
});
