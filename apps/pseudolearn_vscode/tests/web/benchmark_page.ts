import { answerValue, object, text } from "../../src/application/wire_projection";
import { encodeArguments, numeric } from "../../src/application/canonical_arguments";
import type { ApiPort, WasmSessionPort, WireAnswer } from "../../src/contracts/worker_transport";

interface Workload { name: string; source: string; expected: string; cancel?: boolean }
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

async function execute(api: ApiPort, options: Options): Promise<Record<string, unknown>> {
  const started = performance.now();
  const analysis = answerValue(await api.call("create_analysis", encodeArguments({ program: options.workload.source, profile: "es" })));
  const resource = text(answerValue(await api.call("start", encodeArguments({ analysis: numeric(text(analysis.resource)), observe: "events", seed: 42 }))).resource);
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
    if (termination !== "running") break;
    if (options.target === "worker") await new Promise((resolve) => setTimeout(resolve, 0));
  }
  return { milliseconds: performance.now() - started, output, termination, cancelMilliseconds,
    valid: output === options.workload.expected && termination === (options.workload.cancel ? "cancelled" : "completed") };
}

async function benchmark(options: Options): Promise<Record<string, unknown>> {
  const start = performance.now();
  const api = options.target === "worker" ? await workerPort() : await directPort(options.iteration);
  const initializationMilliseconds = performance.now() - start;
  try { return { initializationMilliseconds, ...(await execute(api, options)) }; }
  finally { api.close(); }
}

Object.assign(globalThis, { pseudolearnBenchmark: benchmark });
