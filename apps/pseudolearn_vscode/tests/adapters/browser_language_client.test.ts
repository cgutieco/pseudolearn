import { beforeEach, describe, expect, it, vi } from "vitest";

const captured = vi.hoisted(() => ({ ports: [] as MessagePort[], errors: vi.fn() }));

vi.mock("vscode", () => ({ window: { showErrorMessage: captured.errors }, workspace: { findFiles: vi.fn(), openTextDocument: vi.fn() } }));
vi.mock("vscode-languageclient/browser", () => ({ LanguageClient: class {
  constructor(_a: string, _b: string, readonly connect: () => Promise<unknown>) {}
  sendNotification = vi.fn();
  stop = vi.fn(async () => undefined);
} }));
vi.mock("vscode-languageserver-protocol/browser", () => ({
  BrowserMessageReader: class { constructor(port: MessagePort) { captured.ports.push(port); } },
  BrowserMessageWriter: class { constructor(_port: MessagePort) {} },
}));

import { BrowserLanguageService } from "../../src/adapters/browser_language_client";
import type { WireAnswer } from "../../src/contracts/worker_transport";

type Message = Record<string, unknown>;

function answer(value: unknown): WireAnswer {
  return { response: JSON.stringify(value), projection: value as never };
}

function lspAnswer(...messages: Message[]): WireAnswer {
  return answer({ value: { messages } });
}

async function started(call: (operation: string, argumentsJson: string) => Promise<WireAnswer>) {
  const api = { call: vi.fn(call), close: vi.fn() };
  const service = new BrowserLanguageService(api, { profile: "es", strictness: "strict", locale: "es" });
  await (service.client as unknown as { connect(): Promise<unknown> }).connect();
  const port = captured.ports[captured.ports.length - 1];
  const received: Message[] = [];
  port.onmessage = (event) => received.push(event.data as Message);
  return { api, service, port, received, deliver: (message: Message) => port.postMessage(message) };
}

const tick = () => new Promise<void>((resolve) => setTimeout(resolve, 5));

beforeEach(() => { captured.ports.length = 0; captured.errors.mockClear(); });

describe("Browser language service cancellation", () => {
  it("retires a queued request cancelled before dispatch without calling the Wasm resource", async () => {
    let releaseFirst: (() => void) | undefined;
    const calls: Message[] = [];
    const fixture = await started(async (operation, argumentsJson) => {
      if (operation === "create_lsp") return answer({ value: { resource: "3" } });
      const message = JSON.parse(argumentsJson.replace(/"resource":3/, '"resource":"3"')).message as Message;
      calls.push(message);
      if (calls.length === 1) await new Promise<void>((resolve) => { releaseFirst = resolve; });
      return lspAnswer();
    });
    fixture.deliver({ jsonrpc: "2.0", id: 1, method: "textDocument/hover", params: {} });
    await tick();
    fixture.deliver({ jsonrpc: "2.0", id: 2, method: "textDocument/hover", params: {} });
    fixture.deliver({ jsonrpc: "2.0", method: "$/cancelRequest", params: { id: 2 } });
    await tick();
    releaseFirst?.();
    await tick();
    expect(calls.map((message) => message.id ?? message.method)).toEqual([1, "$/cancelRequest"]);
    expect(fixture.received).toContainEqual({ jsonrpc: "2.0", id: 2, error: { code: -32800, message: "Request cancelled" } });
  });

});

describe("Browser language service synchronous cancellation", () => {
  it("drops the result of a request cancelled during the synchronous call and keeps later answers", async () => {
    let releaseFirst: (() => void) | undefined;
    let first = true;
    const fixture = await started(async (operation) => {
      if (operation === "create_lsp") return answer({ value: { resource: "3" } });
      if (first) {
        first = false;
        await new Promise<void>((resolve) => { releaseFirst = resolve; });
        return lspAnswer({ jsonrpc: "2.0", id: "7", result: { contents: "stale" } });
      }
      return lspAnswer({ jsonrpc: "2.0", id: "8", result: { contents: "fresh" } });
    });
    fixture.deliver({ jsonrpc: "2.0", id: 5, method: "textDocument/hover", params: {} });
    await tick();
    fixture.deliver({ jsonrpc: "2.0", method: "$/cancelRequest", params: { id: 5 } });
    await tick();
    releaseFirst?.();
    await tick();
    expect(JSON.stringify(fixture.received)).not.toContain("stale");
    expect(fixture.received).toContainEqual({ jsonrpc: "2.0", id: 5, error: { code: -32800, message: "Request cancelled" } });
    fixture.deliver({ jsonrpc: "2.0", id: 6, method: "textDocument/hover", params: {} });
    await tick();
    expect(fixture.received).toContainEqual({ jsonrpc: "2.0", id: 6, result: { contents: "fresh" } });
  });

});

describe("Browser language service queue integrity", () => {
  it("never loses a synchronization notification queued behind a slow query", async () => {
    let releaseFirst: (() => void) | undefined;
    const methods: unknown[] = [];
    const fixture = await started(async (operation, argumentsJson) => {
      if (operation === "create_lsp") return answer({ value: { resource: "3" } });
      methods.push((JSON.parse(argumentsJson.replace(/"resource":3/, '"resource":"3"')).message as Message).method);
      if (methods.length === 1) await new Promise<void>((resolve) => { releaseFirst = resolve; });
      return lspAnswer();
    });
    fixture.deliver({ jsonrpc: "2.0", id: 1, method: "textDocument/hover", params: {} });
    await tick();
    fixture.deliver({ jsonrpc: "2.0", method: "textDocument/didChange", params: {} });
    fixture.deliver({ jsonrpc: "2.0", id: 2, method: "textDocument/hover", params: {} });
    fixture.deliver({ jsonrpc: "2.0", method: "$/cancelRequest", params: { id: 1 } });
    await tick();
    releaseFirst?.();
    await tick();
    expect(methods).toEqual(["textDocument/hover", "textDocument/didChange", "textDocument/hover", "$/cancelRequest"]);
  });

});

describe("Browser language service overflow and failure", () => {
  it("closes the session when the notification queue overflows", async () => {
    const fixture = await started(async (operation) => {
      if (operation === "create_lsp") return answer({ value: { resource: "3" } });
      return new Promise<WireAnswer>(() => undefined);
    });
    for (let index = 0; index < 258; index += 1) fixture.deliver({ jsonrpc: "2.0", method: "textDocument/didChange", params: {} });
    await tick();
    expect(fixture.api.close).toHaveBeenCalled();
    expect(captured.errors).toHaveBeenCalled();
  });

  it("closes the API port when a Wasm call fails so the next query starts from a rebuilt session", async () => {
    const fixture = await started(async (operation) => {
      if (operation === "create_lsp") return answer({ value: { resource: "3" } });
      throw new Error("Worker closed");
    });
    fixture.deliver({ jsonrpc: "2.0", id: 1, method: "textDocument/hover", params: {} });
    await tick();
    expect(fixture.api.close).toHaveBeenCalled();
  });
});
