import { mkdtempSync, mkdirSync, writeFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { describe, expect, it } from "vitest";
import {
  bundleViolations,
  hashViolations,
  listingViolations,
  loadContract,
  manifestViolations,
  provenanceViolations,
  sha256,
  sha256File,
  vsixManifestViolations,
} from "../../scripts/lib/artifact.mjs";

const root = resolve(fileURLToPath(new URL("../..", import.meta.url)));
const contract = loadContract(root);
const validListing = [
  "extension.vsixmanifest",
  "[Content_Types].xml",
  ...contract.required.map((name) => `extension/${name}`),
];
const validProvenance = {
  revision: "abc",
  rustc: "rustc 1.99.0",
  cargo: "cargo 1.99.0",
  node: "v22.23.3",
  cargoTarget: contract.target.cargoTarget,
  binarySha256: "b1",
  grammarSha256: "g1",
};

describe("artifact contract", () => {
  it("declares the qualified identity, target and hash algorithm", () => {
    expect(contract.identity.publisher).toBe("pseudolearn");
    expect(contract.target.vscodeTarget).toBe("darwin-arm64");
    expect(contract.hashAlgorithm).toBe("sha256");
    expect(contract.executable).toBe(`bin/${contract.target.vscodeTarget}/pseudo`);
  });

  it("matches the extension manifest", () => {
    const manifest = JSON.parse(
      JSON.stringify({ publisher: "pseudolearn", name: "pseudolearn-vscode", version: "0.1.0", engines: { vscode: "^1.144.0" } }),
    );
    expect(manifestViolations(manifest, contract)).toEqual([]);
    expect(manifestViolations({ ...manifest, version: "9.9.9" }, contract)).not.toEqual([]);
    expect(manifestViolations({ ...manifest, engines: { vscode: "^1.0.0" } }, contract)).not.toEqual([]);
  });
});

describe("VSIX contents", () => {
  it("accepts exactly the declared contents", () => {
    expect(listingViolations(validListing, contract)).toEqual([]);
  });

  it("rejects a missing binary and a missing grammar", () => {
    const withoutBinary = validListing.filter((name) => !name.endsWith("/pseudo"));
    expect(listingViolations(withoutBinary, contract)).toContain("VSIX is missing bin/darwin-arm64/pseudo");
    const withoutGrammar = validListing.filter((name) => !name.endsWith(".tmLanguage.json"));
    expect(listingViolations(withoutGrammar, contract).length).toBe(1);
  });

  it.each([
    "extension/src/activation/extension.ts",
    "extension/tests/a.test.ts",
    "extension/scripts/package.mjs",
    "extension/examples/file/saludo.pseudo",
    "extension/node_modules/x/index.js",
    "extension/.git/config",
    "extension/dist/extension.js.map",
    "extension/.env.local",
    "extension/.artifacts/provenance.json",
  ])("rejects the excluded resource %s", (entry) => {
    expect(listingViolations([...validListing, entry], contract).length).toBeGreaterThan(0);
  });

  it("rejects undeclared resources and binaries for other targets", () => {
    expect(listingViolations([...validListing, "extension/notes.txt"], contract)).toContain(
      "VSIX contains undeclared resource notes.txt",
    );
    expect(listingViolations([...validListing, "extension/bin/linux-x64/pseudo"], contract).length).toBe(1);
  });

  it("checks the target platform declared by the VSIX itself", () => {
    const manifest = `<Identity Version="0.1.0" TargetPlatform="darwin-arm64" />`;
    expect(vsixManifestViolations(manifest, contract)).toEqual([]);
    expect(vsixManifestViolations(manifest.replace("darwin-arm64", "linux-x64"), contract)).not.toEqual([]);
    expect(vsixManifestViolations(manifest.replace("0.1.0", "0.2.0"), contract)).not.toEqual([]);
  });
});

describe("bundle and provenance", () => {
  it("accepts a bundle that contains the language client and requires only vscode and node builtins", () => {
    const bundle = 'var a = "vscode-languageclient"; require("vscode"); require("node:path"); require("child_process");';
    expect(bundleViolations(bundle, contract)).toEqual([]);
  });

  it("rejects a runtime dependency left outside the bundle or absent from it", () => {
    const external = 'var a = "vscode-languageclient"; require("vscode-languageclient/node");';
    expect(bundleViolations(external, contract).length).toBe(1);
    expect(bundleViolations('require("vscode");', contract).length).toBe(1);
  });

  it("requires provenance matching the packaged binary and grammar", () => {
    const actual = { binary: "b1", grammar: "g1" };
    expect(provenanceViolations(validProvenance, actual, contract)).toEqual([]);
    expect(provenanceViolations(undefined, actual, contract)).toEqual(["binary has no provenance record"]);
    expect(provenanceViolations(validProvenance, { ...actual, binary: "tampered" }, contract).length).toBe(1);
    expect(provenanceViolations(validProvenance, { ...actual, binary: undefined }, contract)).toEqual(["packaged binary is missing"]);
    expect(provenanceViolations(validProvenance, { ...actual, grammar: "old" }, contract).length).toBe(1);
    expect(provenanceViolations({ ...validProvenance, cargoTarget: "x86_64-apple-darwin" }, actual, contract).length).toBe(1);
    expect(provenanceViolations({ ...validProvenance, rustc: "" }, actual, contract).length).toBe(1);
  });

  it("detects a hash that differs from the recorded artifact", () => {
    expect(hashViolations({ vsix: "a", binary: "b" }, { vsix: "a", binary: "b" })).toEqual([]);
    expect(hashViolations({ vsix: "a", binary: "b" }, { vsix: "a", binary: "x" })).toEqual([
      "hash of binary differs from the recorded artifact",
    ]);
  });
});

describe("hashing", () => {
  it("is stable for empty content and works in directories with spaces and accents", () => {
    expect(sha256("")).toBe("e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855");
    const directory = mkdtempSync(join(tmpdir(), "ñandú con espacios-"));
    try {
      mkdirSync(join(directory, "bin"));
      writeFileSync(join(directory, "bin", "pseudo"), "binary");
      expect(sha256File(join(directory, "bin", "pseudo"))).toBe(sha256("binary"));
    } finally {
      rmSync(directory, { recursive: true, force: true });
    }
  });
});
