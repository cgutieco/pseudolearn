import { resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { afterEach, describe, expect, it } from "vitest";
import { buildCli, provenancePath } from "../../scripts/build-cli.mjs";

const root = resolve(fileURLToPath(new URL("../..", import.meta.url)));

describe("CLI build script", () => {
  afterEach(() => {
    delete process.env.PSEUDOLEARN_PSEUDO_PATH;
    delete process.env.NODE_ENV;
  });

  it("keeps provenance under the ignored artifact directory", () => {
    expect(provenancePath(root)).toBe(resolve(root, ".artifacts/provenance.json"));
  });

  it("rejects an executable override outside development or with a relative path", () => {
    process.env.PSEUDOLEARN_PSEUDO_PATH = "/tmp/pseudo";
    process.env.NODE_ENV = "production";
    expect(() => buildCli(root)).toThrow("NODE_ENV=development");
    process.env.NODE_ENV = "development";
    process.env.PSEUDOLEARN_PSEUDO_PATH = "relative/pseudo";
    expect(() => buildCli(root)).toThrow("absolute path");
  });
});
