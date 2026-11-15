import { describe, expect, it, vi } from "vitest";

vi.mock("vscode", () => ({ FileType: { File: 1, Directory: 2, SymbolicLink: 64 },
  Uri: { parse: (value: string) => ({ toString: () => value }),
    joinPath: (base: { toString(): string }, path: string) => ({ toString: () => `${base.toString()}/${path}` }) },
  workspace: { fs: { readFile: vi.fn(), writeFile: vi.fn(), stat: vi.fn() } } }));

import { BrowserEffectHost } from "../../src/adapters/browser_effect_host";
import { encodeArguments } from "../../src/application/canonical_arguments";
import type { Projection } from "../../src/contracts/worker_transport";

interface LocalClockReply {
  outcome: string;
  value: { kind: string; value: { nanos: unknown; offset_seconds: number } };
}

const plainEffect = (operation: string, sequence: string, argumentsList: Projection[] = []) =>
  ({ effect_seq: sequence, operation, arguments: argumentsList });

describe("Browser local clock", () => {
  it("reports the instant on the clock scale with a whole-minute offset", async () => {
    const host = new BrowserEffectHost();
    const before = BigInt(Date.now()) * 1_000_000n;
    const reply = await host.perform(plainEffect("clock_local_now", "1")) as LocalClockReply;
    expect(reply.outcome).toBe("committed");
    expect(reply.value.kind).toBe("date_time");
    expect(BigInt(encodeArguments(reply.value.value.nanos))).toBeGreaterThanOrEqual(before);
    expect(Math.abs(reply.value.value.offset_seconds) % 60).toBe(0);
  });

  it("keeps the offset inside the supported range of UTC-12:00 to UTC+14:00", async () => {
    const host = new BrowserEffectHost();
    const reply = await host.perform(plainEffect("clock_local_now", "1")) as LocalClockReply;
    expect(reply.value.value.offset_seconds).toBeGreaterThanOrEqual(-43_200);
    expect(reply.value.value.offset_seconds).toBeLessThanOrEqual(50_400);
  });

  it("rejects a repeated effect sequence", async () => {
    const host = new BrowserEffectHost();
    await host.perform(plainEffect("clock_local_now", "1"));
    const repeated = await host.perform(plainEffect("clock_local_now", "1")) as { outcome: string };
    expect(repeated.outcome).toBe("failed");
  });
});

describe("Browser environment", () => {
  it("has no process environment and answers every read with a typed platform error", async () => {
    const host = new BrowserEffectHost();
    const reply = await host.perform(plainEffect("environment_get", "1", [{ kind: "text", value: "HOME" }]));
    expect(reply).toEqual({ outcome: "failed", value: { code: "permiso_denegado", uncertain: false } });
  });

  it("still grants the capability request so the program can ask for it", async () => {
    const host = new BrowserEffectHost();
    const reply = await host.perform({ ...plainEffect("request_environment", "1"),
      result_capability: { slot: "1", generation: "1", rights: "4", kind: "7" } }) as { outcome: string; value: { kind: string } };
    expect(reply.outcome).toBe("committed");
    expect(reply.value.kind).toBe("capability");
  });
});
