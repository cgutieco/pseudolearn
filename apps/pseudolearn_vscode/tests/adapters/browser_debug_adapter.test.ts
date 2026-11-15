import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { describe, expect, it, vi } from "vitest";

vi.mock("vscode", () => {
  class EventEmitter<T> {
    private listeners: Array<(value: T) => void> = [];
    event = (listener: (value: T) => void) => { this.listeners.push(listener); return { dispose: () => undefined }; };
    fire(value: T) { for (const listener of this.listeners) listener(value); }
    dispose() { this.listeners = []; }
  }
  return { EventEmitter, workspace: { fs: {} }, Uri: { parse: (value: string) => ({ toString: () => value }) } };
});

import { BrowserDebugAdapter } from "../../src/adapters/browser_debug_adapter";
import { debugApi } from "../../src/adapters/browser_debug_target";
import { DebugSession } from "../../src/application/debug_session";
import type { ApiPort, WasmSessionPort } from "../../src/contracts/worker_transport";
import type { DebugEffectPort, DebugTarget } from "../../src/contracts/debug_session";
import { parseProjection } from "../../src/application/wire_projection";
import { AdapterClient } from "../dap/adapter_client";
import { exercise, scenario } from "../dap/scenario.mjs";

const root = resolve(fileURLToPath(new URL("../..", import.meta.url)));
const wasmDirectory = resolve(root, "../../packages/pseudolearn_engine/target/wasm-browser/pkg");
const available = existsSync(resolve(wasmDirectory, "pseudolearn_wasm_bg.wasm"));

async function wasmApi(): Promise<ApiPort> {
  const module = await import(resolve(wasmDirectory, "pseudolearn_wasm.js"));
  await module.default({ module_or_path: readFileSync(resolve(wasmDirectory, "pseudolearn_wasm_bg.wasm")) });
  const session: WasmSessionPort = new module.WasmSession();
  return {
    call: async (operation, argumentsJson) => {
      const answer = JSON.parse(session.callProjected(operation, argumentsJson)) as { response_json: string; projection_json: string };
      return { response: answer.response_json, projection: parseProjection(answer.projection_json) };
    },
    close: () => session.free(),
  };
}

const consoleEffects = (): DebugEffectPort => ({
  perform: async (effect) => {
    const argumentsList = effect.arguments as Array<{ value: string }>;
    const bytes = new TextEncoder().encode(argumentsList[0]?.value ?? "").length;
    return { outcome: "committed", value: { kind: "integer", value: bytes } };
  },
  close: () => undefined,
});

function projectTarget(directory: string): DebugTarget {
  const files = Object.entries(scenario.files as Record<string, string>).filter(([path]) => path.endsWith(".pseudo"))
    .sort(([left], [right]) => left.localeCompare(right, "en"))
    .map(([path, text], index) => ({ path: path.slice(0, -".pseudo".length), source_id: index + 1, text }));
  const manifests = [{ location: "app", text: (scenario.files as Record<string, string>)["app/pseudolearn.toml"]! }];
  return {
    operation: "start_project",
    request: { profile: "es", seed: 42, observe: "events", host: { detached: true }, execution_mode: "live_record",
      project: { project_id: "1", revision_id: "1", manifests, files }, entry: scenario.entry },
    sources: files.map((file) => ({ sourceId: file.source_id, path: join(directory, `${file.path}.pseudo`), text: file.text })),
  };
}

async function debugClient(directory: string) {
  const api = debugApi(await wasmApi());
  const session = new DebugSession({ api, effects: consoleEffects, prepare: async () => projectTarget(directory) });
  const client = new AdapterClient(new BrowserDebugAdapter(session, () => undefined) as never);
  client.onEvent = (event) => {
    const body = event.body as { token?: string } | undefined;
    if (event.event === "pseudolearn/awaitingInput") void client.request("pseudolearn/input", { token: body?.token, action: "line", text: scenario.input });
  };
  return client;
}

describe("browser debug adapter over the real Wasm VM", () => {
  it.skipIf(!available)("stops at a breakpoint, inspects tasks and steps back like the desktop adapter", async () => {
    const directory = mkdtempSync(join(tmpdir(), "pseudolearn-dap-wasm-"));
    for (const [relative, text] of Object.entries(scenario.files as Record<string, string>)) {
      mkdirSync(dirname(join(directory, relative)), { recursive: true });
      writeFileSync(join(directory, relative), text);
    }
    try {
      const client = await debugClient(directory);
      const capabilities = await client.request("initialize", { adapterID: "pseudolearn-web", linesStartAt1: true, columnsStartAt1: true });
      expect(capabilities.supportsStepBack).toBe(true);
      await client.request("launch", { project: directory, entry: scenario.entry, stopOnEntry: false });
      await client.waitEvent("initialized");
      const breakpoints = await client.request("setBreakpoints", { source: { path: join(directory, scenario.breakpoint.path) },
        breakpoints: [{ line: scenario.breakpoint.line }, { line: 2, condition: "x" }] });
      expect(breakpoints.breakpoints[1]).toEqual({ verified: false, message: "conditional and log breakpoints are unavailable" });
      await client.request("configurationDone");
      const projection = await exercise(client, directory);
      const report = resolve(root, ".artifacts/dap-wasm");
      mkdirSync(report, { recursive: true });
      writeFileSync(join(report, "projection.json"), JSON.stringify(projection, null, 2));
      expect(projection.expression).toBe("21");
      await client.request("disconnect");
    } finally {
      rmSync(directory, { recursive: true, force: true });
    }
  }, 60000);

  it.skipIf(!available)("rejects requests that are invalid before launch", async () => {
    const client = await debugClient(tmpdir());
    await expect(client.request("configurationDone")).rejects.toThrow("configurationDone is invalid");
    await expect(client.request("continue")).rejects.toThrow("not configured");
    await expect(client.request("unknownCommand")).rejects.toThrow("unsupported debug request");
    await client.request("initialize", { pathFormat: "path" });
    await expect(client.request("initialize")).rejects.toThrow("already initialized");
  });
});
