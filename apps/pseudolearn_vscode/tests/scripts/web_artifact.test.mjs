import { describe, expect, it } from "vitest";
import { globalViolations, graphViolations, inventoryViolations } from "../../scripts/lib/web-artifact.mjs";

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
  it("rejects missing Workers and extra native binaries", () => {
    expect(inventoryViolations(["package.json"], ["package.json", "worker.js"])).not.toEqual([]);
    expect(inventoryViolations(["package.json", "bin/pseudo"], ["package.json"])).not.toEqual([]);
  });
});
