import { describe, expect, it, vi } from "vitest";

vi.mock("vscode", () => ({ FileType: { File: 1, Directory: 2, SymbolicLink: 64 },
  Uri: { parse: (value: string) => ({ toString: () => value }),
    joinPath: (base: { toString(): string }, path: string) => ({ toString: () => `${base.toString()}/${path}` }) },
  workspace: { fs: { readFile: vi.fn(), writeFile: vi.fn(), stat: vi.fn() } } }));

import { BrowserEffectHost } from "../../src/adapters/browser_effect_host";
import type { Projection } from "../../src/contracts/worker_transport";

const effect = (operation: string, argumentsList: Projection[]) =>
  ({ effect_seq: "1", operation, arguments: argumentsList });

describe("Browser console error stream", () => {
  it("confirms the byte count and leaves the text to the merged program output", async () => {
    const host = new BrowserEffectHost();
    const reply = await host.perform(effect("console_write_error", [{ kind: "text", value: "é" }])) as { outcome: string };
    expect(reply.outcome).toBe("committed");
  });
});

describe("Browser exit code", () => {
  it("accepts every code from zero to 255", async () => {
    for (const code of ["0", "7", "255"]) {
      const host = new BrowserEffectHost();
      const reply = await host.perform(effect("console_set_exit_code", [{ kind: "integer", value: code }])) as { outcome: string };
      expect(reply.outcome).toBe("committed");
    }
  });

  it("rejects codes outside the range with a request error", async () => {
    for (const code of ["-1", "256"]) {
      const host = new BrowserEffectHost();
      const reply = await host.perform(effect("console_set_exit_code", [{ kind: "integer", value: code }]));
      expect(reply).toEqual({ outcome: "failed", value: { code: "peticion_invalida", uncertain: false } });
    }
  });
});
