import { answerValue, object, text } from "../../src/application/wire_projection";
import { encodeArguments, numeric } from "../../src/application/canonical_arguments";
import type { ApiPort, Projection, WasmSessionPort, WireAnswer } from "../../src/contracts/worker_transport";
import { NETWORK_CAPABILITIES, performFetch } from "../../../../packages/pseudolearn_engine/crates/pseudolearn_wasm/browser/fetch_host.mjs";
import { toFetchEffect } from "../../src/adapters/browser_fetch_effect";

interface Workload { name: string; kind?: "program" | "project" | "edit"; source?: string; project?: unknown; expected: string;
  cancel?: boolean; network?: boolean }
interface Options { target: string; workload: Workload; iteration: number }

async function directPort(iteration: number): Promise<ApiPort> {
  const url = `/dist/web/wasm/pseudolearn_wasm.js?instance=${iteration}-${performance.now()}`;
  const module = await import(url);
  await module.default();
  const session: WasmSessionPort = new module.WasmSession();
  return { call: async (operation, argumentsJson) => {
    const answer = JSON.parse(session.callProjected(operation, argumentsJson));
    return { response: answer.response_json, projection: JSON.parse(answer.projection_json) };
  }, close: () => session.free() };
}

async function workerPort(): Promise<ApiPort> {
  const worker = new Worker("/dist/web/execution_worker.js", { type: "module" });
  let sequence = 0;
  const pending = new Map<number, (answer: Record<string, string>) => void>();
  worker.onmessage = ({ data }) => { pending.get(data.request)?.(data); pending.delete(data.request); };
  const send = (kind: string, operation: string, payload: string): Promise<Record<string, string>> => new Promise((resolve) => {
    const request = ++sequence;
    pending.set(request, resolve);
    worker.postMessage({ schema: 1, channel: "execution", session: "benchmark", generation: 1, request, kind, operation, payload });
  });
  await send("initialize", "", `${location.origin}/dist/web/wasm/pseudolearn_wasm.js`);
  return { call: async (operation, argumentsJson): Promise<WireAnswer> => {
    const answer = await send("call", operation, argumentsJson);
    if (answer.kind === "failure") throw new Error(answer.payload);
    return { response: answer.payload!, projection: JSON.parse(answer.projection!) };
  }, close: () => worker.terminate() };
}

const fakeOrigin = "https:" + "//fake.test";

async function resolveEffect(api: ApiPort, resource: string, effect: Record<string, Projection>): Promise<void> {
  const sequence = numeric(text(effect.effect_seq));
  let result: unknown;
  if (effect.operation === "request_network") {
    const capability = Object.fromEntries(Object.entries(object(effect.result_capability)).map(([name, value]) => [name, numeric(text(value))]));
    result = { outcome: "committed", value: { kind: "capability", value: capability } };
  } else {
    result = await performFetch(toFetchEffect(effect), { allowedOrigins: [fakeOrigin],
      fetchImplementation: async () => new Response("ok", { status: 200 }) });
  }
  await api.call("effect_result", encodeArguments({ resource: numeric(resource), effect_seq: sequence, result }));
}

async function start(api: ApiPort, workload: Workload): Promise<string> {
  const host = workload.network ? { detached: true, permissions: ["red"], network_origins: [fakeOrigin] } : undefined;
  if (workload.network) await api.call("negotiate", encodeArguments({ network_capabilities: NETWORK_CAPABILITIES }));
  const common = { profile: "es", observe: "events", seed: 42, host, execution_mode: host ? "live_record" : undefined };
  if (workload.kind === "project") {
    return text(answerValue(await api.call("start_project", encodeArguments({ ...common, project: workload.project, entry: "app/main" }))).resource);
  }
  const analysis = answerValue(await api.call("create_analysis", encodeArguments({ program: workload.source, profile: "es" })));
  return text(answerValue(await api.call("start", encodeArguments({ ...common, analysis: numeric(text(analysis.resource)) }))).resource);
}

async function execute(api: ApiPort, options: Options): Promise<Record<string, unknown>> {
  const started = performance.now();
  const resource = await start(api, options.workload);
  let output = "";
  let termination = "running";
  let cancelMilliseconds: number | null = null;
  for (let batch = 0; batch < 100000; batch += 1) {
    if (options.workload.cancel && batch === 10) {
      const cancelStarted = performance.now();
      await api.call("cancel", encodeArguments({ resource: numeric(resource) }));
      const result = answerValue(await api.call("advance", encodeArguments({ resource: numeric(resource), batch_size: 64 })));
      cancelMilliseconds = performance.now() - cancelStarted;
      termination = text(object(result.termination).kind);
      break;
    }
    const answer = answerValue(await api.call("advance", encodeArguments({ resource: numeric(resource), batch_size: 64 })));
    output = text(answer.output);
    termination = text(object(answer.termination).kind);
    if (termination === "awaiting_effect") await resolveEffect(api, resource, object(answer.pending_effect));
    else if (termination !== "running") break;
    if (options.target === "worker") await new Promise((resolve) => setTimeout(resolve, 0));
  }
  return { milliseconds: performance.now() - started, output, termination, cancelMilliseconds,
    valid: output === options.workload.expected && termination === (options.workload.cancel ? "cancelled" : "completed") };
}

async function lspRound(api: ApiPort, resource: string, message: unknown): Promise<Record<string, Projection>[]> {
  const answer = answerValue(await api.call("lsp_message", encodeArguments({ resource: numeric(resource), message })));
  return answer.messages as Record<string, Projection>[];
}

async function edit(api: ApiPort, options: Options): Promise<Record<string, unknown>> {
  const started = performance.now();
  const resource = text(answerValue(await api.call("create_lsp", "{}")).resource);
  const uri = "file:" + "///edit.pseudo";
  await lspRound(api, resource, { jsonrpc: "2.0", id: 1, method: "initialize", params: { processId: null, rootUri: null, capabilities: {},
    initializationOptions: { profile: "es", strictness: "strict", locale: "es" } } });
  await lspRound(api, resource, { jsonrpc: "2.0", method: "initialized", params: {} });
  await lspRound(api, resource, { jsonrpc: "2.0", method: "textDocument/didOpen",
    params: { textDocument: { uri, languageId: "pseudolearn", version: 1, text: options.workload.source } } });
  let diagnostics = -1;
  for (let version = 2; version <= 21; version += 1) {
    const broken = version % 2 === 1 && version < 21;
    const content = broken ? `${options.workload.source}Broken(` : options.workload.source;
    const messages = await lspRound(api, resource, { jsonrpc: "2.0", method: "textDocument/didChange",
      params: { textDocument: { uri, version }, contentChanges: [{ text: content }] } });
    const published = messages.find((message) => message.method === "textDocument/publishDiagnostics");
    diagnostics = ((object(published?.params).diagnostics as Projection[]) ?? []).length;
  }
  const output = `edits:20 diagnostics:${diagnostics}\n`;
  return { milliseconds: performance.now() - started, output, termination: "completed", cancelMilliseconds: null, valid: output === options.workload.expected };
}

async function benchmark(options: Options): Promise<Record<string, unknown>> {
  const start = performance.now();
  const api = options.target === "worker" ? await workerPort() : await directPort(options.iteration);
  const initializationMilliseconds = performance.now() - start;
  try { return { initializationMilliseconds, ...(await (options.workload.kind === "edit" ? edit(api, options) : execute(api, options))) }; }
  finally { api.close(); }
}

Object.assign(globalThis, { pseudolearnBenchmark: benchmark });
