import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { BrowserWorkerClient } from "../../src/adapters/browser_worker_client";
import type { WorkerEnvelope } from "../../src/contracts/worker_transport";
import { maximumPendingRequests } from "../../src/application/worker_protocol";

class FakeWorker {
  onmessage: ((event: { data: unknown }) => void) | null = null;
  onerror: ((event: { message?: string }) => void) | null = null;
  onmessageerror: (() => void) | null = null;
  readonly sent: WorkerEnvelope[] = [];
  terminated = false;
  postMessage(value: WorkerEnvelope): void { this.sent.push(value); }
  terminate(): void { this.terminated = true; }
  reply(request: WorkerEnvelope, overrides: Partial<WorkerEnvelope> = {}): void {
    this.onmessage?.({ data: { ...request, kind: "result", payload: "{}", projection: "{}", ...overrides } });
  }
  ready(): void { this.reply(this.sent[0], { kind: "ready", payload: "null", projection: "null" }); }
}

function client(worker: FakeWorker, channel: "language" | "execution" = "execution", session = "s1") {
  return new BrowserWorkerClient(worker as unknown as Worker, { channel, session, generation: 1, wasm: "wasm.js" });
}

async function settle(): Promise<void> { await Promise.resolve(); await Promise.resolve(); }

beforeEach(() => vi.useFakeTimers());
afterEach(() => vi.useRealTimers());

describe("Browser Worker client failure isolation", () => {

  it("keeps a failing Worker from affecting its sibling", async () => {
    const language = new FakeWorker();
    const execution = new FakeWorker();
    const languageClient = client(language, "language", "l");
    const executionClient = client(execution, "execution", "e");
    language.ready();
    execution.ready();
    await languageClient.ready;
    await executionClient.ready;
    const failing = languageClient.call("lsp_message", "{}");
    const running = executionClient.call("advance", "{}");
    await settle();
    language.onerror?.({ message: "boom" });
    await expect(failing).rejects.toThrow("Worker failed: boom");
    expect(language.terminated).toBe(true);
    expect(execution.terminated).toBe(false);
    execution.reply(execution.sent[1], { payload: '{"value":1}', projection: '{"value":{"output":"ok"}}' });
    await expect(running).resolves.toEqual({ response: '{"value":1}', projection: { value: { output: "ok" } } });
    await expect(languageClient.call("lsp_message", "{}")).rejects.toThrow();
  });

  it("closes the session and rejects pending calls after a timeout so state is rebuilt from scratch", async () => {
    const worker = new FakeWorker();
    const timedOut = client(worker);
    worker.ready();
    await timedOut.ready;
    const pending = timedOut.call("lsp_message", "{}");
    const outcome = expect(pending).rejects.toThrow("full resynchronization required");
    await vi.advanceTimersByTimeAsync(30001);
    await outcome;
    expect(worker.terminated).toBe(true);
    await expect(timedOut.call("lsp_message", "{}")).rejects.toThrow("Worker unavailable or saturated");
  });

});

describe("Browser Worker client answer correlation", () => {
  it("ignores answers from another session, channel, generation or unknown request", async () => {
    const worker = new FakeWorker();
    const subject = client(worker);
    worker.ready();
    await subject.ready;
    const pending = subject.call("advance", "{}");
    await settle();
    const request = worker.sent[1];
    let settled = false;
    void pending.then(() => { settled = true; }, () => { settled = true; });
    worker.reply(request, { session: "other" });
    worker.reply(request, { channel: "language" });
    worker.reply(request, { generation: 2 });
    worker.reply({ ...request, request: 999 });
    worker.onmessage?.({ data: { schema: 2 } });
    await settle();
    expect(settled).toBe(false);
    worker.reply(request);
    await expect(pending).resolves.toMatchObject({ response: "{}" });
  });

});

describe("Browser Worker client numeric exactness", () => {
  it("forwards extreme 64-bit values as text in both directions without rounding", async () => {
    const worker = new FakeWorker();
    const subject = client(worker);
    worker.ready();
    await subject.ready;
    const argumentsJson = '{"seed":18446744073709551615,"value":-9223372036854775808}';
    const pending = subject.call("start", argumentsJson);
    await settle();
    expect(worker.sent[1].payload).toBe(argumentsJson);
    const answer = '{"value":{"total":9223372036854775807}}';
    worker.reply(worker.sent[1], { payload: answer, projection: '{"value":{"total":"9223372036854775807"}}' });
    const result = await pending;
    expect(result.response).toBe(answer);
    expect(result.projection).toEqual({ value: { total: "9223372036854775807" } });
  });

  it("rejects a projection holding an unquoted number and closes the Worker", async () => {
    const worker = new FakeWorker();
    const subject = client(worker);
    worker.ready();
    await subject.ready;
    const pending = subject.call("advance", "{}");
    await settle();
    worker.reply(worker.sent[1], { projection: '{"value":18446744073709551615}' });
    await expect(pending).rejects.toThrow("Invalid Worker projection");
    expect(worker.terminated).toBe(true);
  });

});

describe("Browser Worker client limits", () => {
  it("refuses requests beyond the pending limit without dropping earlier ones", async () => {
    const worker = new FakeWorker();
    const subject = client(worker);
    worker.ready();
    await subject.ready;
    const accepted = Array.from({ length: maximumPendingRequests }, () => subject.call("lsp_message", "{}"));
    await settle();
    await expect(subject.call("lsp_message", "{}")).rejects.toThrow("saturated");
    expect(worker.sent.length).toBe(1 + maximumPendingRequests);
    worker.reply(worker.sent[1]);
    await expect(accepted[0]).resolves.toMatchObject({ response: "{}" });
  });

  it("releases every pending call when closed", async () => {
    const worker = new FakeWorker();
    const subject = client(worker);
    worker.ready();
    await subject.ready;
    const first = subject.call("advance", "{}");
    await settle();
    subject.close();
    await expect(first).rejects.toThrow("Worker closed");
    expect(worker.terminated).toBe(true);
    subject.close();
  });
});
