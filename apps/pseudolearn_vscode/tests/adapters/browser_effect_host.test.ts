import { afterEach, describe, expect, it, vi } from "vitest";

const provider = vi.hoisted(() => ({ reads: vi.fn(), writes: vi.fn(), stat: vi.fn() }));

vi.mock("vscode", () => ({ FileType: { File: 1, Directory: 2, SymbolicLink: 64 },
  Uri: { parse: (value: string) => ({ toString: () => value }),
    joinPath: (base: { toString(): string }, path: string) => ({ toString: () => `${base.toString()}/${path}` }) },
  workspace: { fs: { readFile: provider.reads, writeFile: provider.writes, stat: provider.stat } } }));

import { BrowserEffectHost } from "../../src/adapters/browser_effect_host";

const origin = "https://granted.example.test";

function sendEffect(sequence: string, overrides: Record<string, unknown> = {}) {
  return { effect_seq: sequence, operation: "network_send", arguments: [{ kind: "http_request", value: {
    method: "GET", url: `${origin}/resource`, headers: [], body: null,
    effective_response_limit: "16", effective_timeout_nanos: "1000000000", ...overrides } }] };
}

function stubFetch(implementation: (url: string, init: RequestInit) => Promise<Response>) {
  const calls = vi.fn(implementation);
  vi.stubGlobal("fetch", calls);
  return calls;
}

afterEach(() => {
  vi.unstubAllGlobals();
  vi.clearAllMocks();
});

describe("Browser effect host network resolution", () => {
  it("resolves a granted request once and rejects a replayed sequence", async () => {
    const calls = stubFetch(async () => new Response(new Uint8Array([111, 107]), { status: 200 }));
    const host = new BrowserEffectHost({ });
    const first = await host.perform(sendEffect("1")) as { outcome: string; value: { value: { body: number[] } } };
    expect(first.outcome).toBe("committed");
    expect(first.value.value.body).toEqual([111, 107]);
    expect(await host.perform(sendEffect("1"))).toEqual({ outcome: "failed", value: { code: "interrumpido", uncertain: false } });
    expect(calls).toHaveBeenCalledTimes(1);
  });

  it("accepts an HTTP destination without origin configuration", async () => {
    const calls = stubFetch(async () => new Response(null));
    const host = new BrowserEffectHost();
    expect((await host.perform(sendEffect("1")) as { outcome: string }).outcome).toBe("committed");
    expect(calls).toHaveBeenCalledTimes(1);
  });

});

describe("Browser effect host closed and revoked sessions", () => {
  it("makes no physical call after the host closes", async () => {
    const calls = stubFetch(async () => new Response(null));
    const host = new BrowserEffectHost({ });
    host.close();
    expect(await host.perform(sendEffect("1"))).toEqual({ outcome: "failed", value: { code: "interrumpido", uncertain: false } });
    expect(calls).not.toHaveBeenCalled();
  });

  it("keeps authority between requests without a grant store", async () => {
    const calls = stubFetch(async () => new Response(null, { status: 204 }));
    const host = new BrowserEffectHost();
    await host.perform(sendEffect("1"));
    await host.perform(sendEffect("2"));
    expect(calls).toHaveBeenCalledTimes(2);
  });

});

describe("Browser effect host stale sessions", () => {
  it("aborts an in-flight request when the session closes and keeps a new session independent", async () => {
    let release: (() => void) | undefined;
    const calls = stubFetch((_url, init) => new Promise((resolve, reject) => {
      if (calls.mock.calls.length === 1) {
        init.signal?.addEventListener("abort", () => reject(new DOMException("aborted", "AbortError")), { once: true });
        release = () => resolve(new Response(new Uint8Array([9]), { status: 200 }));
      } else resolve(new Response(new Uint8Array([7]), { status: 200 }));
    }));
    const stale = new BrowserEffectHost({ });
    const pending = stale.perform(sendEffect("1", { method: "POST" }));
    await vi.waitFor(() => expect(calls).toHaveBeenCalledTimes(1));
    stale.close();
    const aborted = await pending as { outcome: string; value: { code: string } };
    expect(aborted).toEqual({ outcome: "uncertain", value: { code: "interrumpido", uncertain: true } });
    release?.();
    const fresh = new BrowserEffectHost({ });
    const answer = await fresh.perform(sendEffect("1")) as { outcome: string; value: { value: { body: number[] } } };
    expect(answer.outcome).toBe("committed");
    expect(answer.value.value.body).toEqual([7]);
  });

  it("reports a network failure of a read as a plain failure", async () => {
    stubFetch(async () => { throw new TypeError("network"); });
    const host = new BrowserEffectHost({ });
    expect(await host.perform(sendEffect("1"))).toEqual({ outcome: "failed", value: { code: "conexion_fallida", uncertain: false } });
  });
});

describe("Browser effect host file isolation", () => {
  const directory = { slot: "1", generation: "1", rights: "3", kind: "2" };

  it("never reaches the provider without a file grant", async () => {
    const host = new BrowserEffectHost({ });
    const denied = await host.perform({ effect_seq: "1", operation: "request_directory", result_capability: directory,
      arguments: [{ kind: "text", value: "root" }] }) as { outcome: string };
    expect(denied.outcome).toBe("failed");
    expect(provider.reads).not.toHaveBeenCalled();
    expect(provider.writes).not.toHaveBeenCalled();
    expect(provider.stat).not.toHaveBeenCalled();
  });
});
