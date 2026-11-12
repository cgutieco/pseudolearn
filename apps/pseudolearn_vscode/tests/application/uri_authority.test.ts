import { describe, expect, it } from "vitest";
import { containsUri } from "../../src/application/uri_authority";

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

  it("keeps voluntary root confinement separate from sibling prefixes", () => {
    expect(containsUri("memfs://host/root", "memfs://host/root/a")).toBe(true);
    expect(containsUri("memfs://host/root", "memfs://host/root-two/a")).toBe(false);
  });
});
