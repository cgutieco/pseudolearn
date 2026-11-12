import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { describe, expect, it, vi } from "vitest";

vi.mock("vscode", () => ({ FileType: { File: 1, Directory: 2, SymbolicLink: 64 },
  Uri: { parse: (value: string) => ({ toString: () => value }),
    joinPath: (base: { toString(): string }, path: string) => ({ toString: () => `${base.toString()}/${path}` }) },
  workspace: { fs: { readFile: vi.fn(), writeFile: vi.fn(), stat: vi.fn() } } }));

import { BrowserEffectHost } from "../../src/adapters/browser_effect_host";
import { BROWSER_OPERATION_SUPPORT } from "../../src/adapters/browser_operation_support";

interface LibraryOperation { identity: string; effect: boolean }

const exportPath = resolve(__dirname, "../../../../packages/pseudolearn_spec/specifications/export.json");

function effectOperations(): string[] {
  const exported = JSON.parse(readFileSync(exportPath, "utf8")) as { resources: { capabilityLibrary: { operations: LibraryOperation[] } } };
  return exported.resources.capabilityLibrary.operations.filter((operation) => operation.effect).map((operation) => operation.identity);
}

function undeclaredOperations(declared: Record<string, unknown>, exported: string[]): string[] {
  return exported.filter((operation) => !(operation in declared));
}

describe("Browser operation coverage", () => {
  it("declares a branch for every effect operation of the library", () => {
    expect(undeclaredOperations(BROWSER_OPERATION_SUPPORT, effectOperations())).toEqual([]);
  });

  it("declares no operation the library no longer exports", () => {
    const exported = new Set(effectOperations());
    expect(Object.keys(BROWSER_OPERATION_SUPPORT).filter((name) => !exported.has(name))).toEqual([]);
  });

  it("fails when an exported operation has no branch", () => {
    const withoutBranch = { ...BROWSER_OPERATION_SUPPORT };
    delete (withoutBranch as Record<string, unknown>).clock_local_now;
    expect(undeclaredOperations(withoutBranch, effectOperations())).toEqual(["clock_local_now"]);
  });

  it("answers the declared platform error for the environment", async () => {
    const host = new BrowserEffectHost();
    const reply = await host.perform({ effect_seq: "1", operation: "environment_get", arguments: [] }) as { outcome: string };
    expect(BROWSER_OPERATION_SUPPORT.environment_get).toBe("platform_error");
    expect(reply.outcome).toBe("failed");
  });

  it("answers every declared value operation with an outcome", async () => {
    const host = new BrowserEffectHost();
    const stateless = ["console_write_error", "console_set_exit_code", "arguments_values", "clock_now", "clock_local_now", "network_close"];
    for (const [index, operation] of stateless.entries()) {
      const argumentsList = operation === "console_write_error"
        ? [{ type: "text", value: "x" }] : operation === "console_set_exit_code" ? [{ type: "integer", value: "3" }] : [];
      const reply = await host.perform({ effect_seq: String(index + 10), operation, arguments: argumentsList }) as { outcome: string };
      expect(reply.outcome, operation).toBeDefined();
    }
  });
});
