import { afterEach, describe, expect, it, vi } from "vitest";

const host = vi.hoisted(() => ({ trusted: true, input: vi.fn() }));

vi.mock("vscode", () => ({
  workspace: { get isTrusted() { return host.trusted; }, fs: {} },
  window: { showInputBox: host.input },
  FileType: { File: 1, Directory: 2, SymbolicLink: 64 },
  Uri: { parse: (value: string) => ({ toString: () => value }) },
}));

import { BrowserRun } from "../../src/adapters/browser_run";
import type { WireAnswer } from "../../src/contracts/worker_transport";

const answer = (value: unknown): WireAnswer => ({ response: JSON.stringify({ value }), projection: { value } as never });
const running = () => answer({ output: "", termination: { kind: "running" } });

function fixture(advance: () => WireAnswer | Promise<WireAnswer>) {
  const operations: string[] = [];
  const output: string[] = [];
  const api = { close: vi.fn(), call: vi.fn(async (operation: string, _argumentsJson?: string) => {
    operations.push(operation);
    if (operation === "create_analysis") return answer({ resource: "5" });
    if (operation === "start") return answer({ resource: "6" });
    if (operation === "advance") return advance();
    return answer(null);
  }) };
  const channel = { append: (text: string) => output.push(text), appendLine: (text: string) => output.push(`${text}\n`) };
  return { api, operations, output, run: new BrowserRun(api, channel as never) };
}

const wait = (milliseconds: number) => new Promise<void>((resolve) => setTimeout(resolve, milliseconds));

afterEach(() => { host.trusted = true; vi.clearAllMocks(); vi.unstubAllGlobals(); });

describe("Browser run batching and cancellation", () => {
  it("honours a stop between batches, cancelling once and releasing every resource", async () => {
    let cancelled = false;
    const subject = fixture(() => cancelled ? answer({ output: "", termination: { kind: "cancelled" } }) : running());
    subject.api.call.mockImplementation(async (operation: string) => {
      subject.operations.push(operation);
      if (operation === "cancel") cancelled = true;
      if (operation === "create_analysis") return answer({ resource: "5" });
      if (operation === "start") return answer({ resource: "6" });
      if (operation === "advance") return cancelled ? answer({ output: "", termination: { kind: "cancelled" } }) : running();
      return answer(null);
    });
    const finished = subject.run.start({ source: "x" }, { });
    await wait(30);
    expect(subject.operations.filter((operation) => operation === "advance").length).toBeGreaterThan(1);
    await subject.run.stop();
    await finished;
    expect(subject.operations.filter((operation) => operation === "cancel")).toHaveLength(1);
    expect(subject.operations.filter((operation) => operation === "release")).toHaveLength(2);
    expect(subject.output.join("")).toContain("PseudoLearn: cancelled");
    expect(subject.operations.lastIndexOf("advance")).toBeLessThan(subject.operations.indexOf("release"));
  });

  it("rejects a second run and an untrusted workspace before touching the engine", async () => {
    const subject = fixture(() => running());
    host.trusted = false;
    await expect(subject.run.start({ source: "x" }, { })).rejects.toThrow("Workspace trust is required");
    expect(subject.api.call).not.toHaveBeenCalled();
  });
});

describe("Browser run stale effect handling", () => {
  it("does not deliver an effect result produced after the stop", async () => {
    let release: (() => void) | undefined;
    vi.stubGlobal("fetch", () => new Promise<Response>((resolve) => { release = () => resolve(new Response(new Uint8Array([1]))); }));
    const effect = { effect_seq: "1", operation: "network_send", arguments: [{ kind: "http_request", value: {
      method: "GET", url: "https://granted.example.test/x", headers: [], body: null,
      effective_response_limit: "4", effective_timeout_nanos: "1000000000" } }] };
    const subject = fixture(() => answer({ output: "", termination: { kind: "awaiting_effect" }, pending_effect: effect }));
    subject.api.call.mockImplementation(async (operation: string) => {
      subject.operations.push(operation);
      if (operation === "start") return answer({ resource: "6" });
      if (operation === "create_analysis") return answer({ resource: "5" });
      if (operation === "advance") return subject.operations.includes("cancel")
        ? answer({ output: "", termination: { kind: "cancelled" } })
        : answer({ output: "", termination: { kind: "awaiting_effect" }, pending_effect: effect });
      return answer(null);
    });
    const finished = subject.run.start({ source: "x" }, { });
    await wait(20);
    await subject.run.stop();
    release?.();
    await finished;
    expect(subject.operations).not.toContain("effect_result");
  });
});

describe("Browser run input cancellation", () => {
  it("cancels and resumes the waiting run so the cancellation takes effect", async () => {
    host.input.mockResolvedValueOnce(undefined);
    let cancelled = false;
    const subject = fixture(() => running());
    subject.api.call.mockImplementation(async (operation: string) => {
      subject.operations.push(operation);
      if (operation === "cancel") cancelled = true;
      if (operation === "create_analysis") return answer({ resource: "5" });
      if (operation === "start") return answer({ resource: "6" });
      if (operation === "advance") return answer({ output: "", termination: { kind: cancelled ? "cancelled" : "awaiting_input" } });
      return answer(null);
    });
    await subject.run.start({ source: "x" }, { });
    const order = subject.operations.filter((operation) => ["cancel", "input"].includes(operation));
    expect(order).toEqual(["cancel"]);
    expect(subject.output.join("")).toContain("PseudoLearn: cancelled");
  });
});

describe("Browser input identity", () => {
  it("returns the exact waiting task and request identities", async () => {
    host.input.mockResolvedValueOnce("");
    let supplied = false;
    let submitted: unknown;
    const subject = fixture(() => running());
    subject.api.call.mockImplementation(async (operation: string, argumentsJson?: string) => {
      if (operation === "create_analysis") return answer({ resource: "5" });
      if (operation === "start") return answer({ resource: "6" });
      if (operation === "advance") return answer({ output: "", termination: { kind: supplied ? "completed" : "awaiting_input" },
        pending_input: { resource_id: "6", task_id: "2", request_id: "3" } });
      if (operation === "input") { submitted = JSON.parse(argumentsJson!); supplied = true; }
      return answer(null);
    });
    await subject.run.start({ source: "x" }, {});
    expect(submitted).toEqual({ resource: 6, text: "", resource_id: 6, task_id: 2, request_id: 3 });
  });
});
