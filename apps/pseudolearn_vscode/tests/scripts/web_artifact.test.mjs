import { describe, expect, it } from "vitest";
import { mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { globalViolations, graphViolations, hash, hashViolations, inventoryViolations, memoryMaximum } from "../../scripts/lib/web-artifact.mjs";

function stagedFile(content) {
  const directory = mkdtempSync(join(tmpdir(), "web-artifact-"));
  writeFileSync(join(directory, "worker.js"), content);
  return directory;
}

describe("Web artifact checks", () => {
  it("accepts the declared browser graph and inventory", () => {
    expect(graphViolations({ inputs: { "src/activation/browser_extension.ts": { imports: [{ path: "vscode", external: true }] } } })).toEqual([]);
    expect(inventoryViolations(["package.json", "worker.js"], ["package.json", "worker.js"])).toEqual([]);
  });
  it("rejects transitive Node and unexpected external imports", () => {
    expect(graphViolations({ inputs: { "dependency.js": { imports: [{ path: "node:fs", external: true }] } } })).not.toEqual([]);
    expect(graphViolations({ inputs: { "dependency.js": { imports: [{ path: "https://remote.test/code.js", external: true }] } } })).not.toEqual([]);
    expect(graphViolations({ inputs: { "../../undeclared.js": { imports: [] } } })).not.toEqual([]);
    expect(globalViolations("process.env.SECRET")).not.toEqual([]);
    expect(globalViolations("const flags = { global: 1 }; flags.global;")).toEqual([]);
  });
  it("accepts matching hashes and rejects wrong, missing and unreadable files", () => {
    const directory = stagedFile("worker");
    const digest = hash(join(directory, "worker.js"));
    expect(hashViolations(directory, { "worker.js": digest }, "Hash mismatch")).toEqual([]);
    expect(hashViolations(directory, { "worker.js": "0".repeat(64) }, "Hash mismatch")).toEqual(["Hash mismatch: worker.js"]);
    expect(hashViolations(directory, { "absent.js": digest }, "Hash mismatch")).toEqual(["Hash mismatch: absent.js (unreadable)"]);
    expect(hashViolations(directory, {}, "Hash mismatch")).toEqual([]);
  });
  it("rejects a Wasm module without one private bounded memory", () => {
    const header = [0, 0x61, 0x73, 0x6d, 1, 0, 0, 0];
    const bounded = new Uint8Array([...header, 5, 4, 1, 1, 1, 8]);
    expect(memoryMaximum(bounded)).toBe(8);
    expect(() => memoryMaximum(new Uint8Array(header))).toThrow("Wasm memory section is missing");
    expect(() => memoryMaximum(new Uint8Array([...header, 5, 3, 1, 0, 1]))).toThrow("Expected one private bounded Wasm memory");
    expect(() => memoryMaximum(new Uint8Array([...header, 5, 2, 1]))).toThrow();
  });
  it("rejects missing Workers and extra native binaries", () => {
    expect(inventoryViolations(["package.json"], ["package.json", "worker.js"])).not.toEqual([]);
    expect(inventoryViolations(["package.json", "bin/pseudo"], ["package.json"])).not.toEqual([]);
  });
});
