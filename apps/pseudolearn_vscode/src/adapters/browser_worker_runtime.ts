import type { WasmSessionPort, WorkerChannel, WorkerEnvelope } from "../contracts/worker_transport";
import { validateEnvelope } from "../application/worker_protocol";

interface WorkerScope {
  onmessage: ((event: MessageEvent) => void) | null;
  postMessage(value: unknown): void;
  close(): void;
}

export function startWorker(channel: WorkerChannel): void {
  const scope = globalThis as unknown as WorkerScope;
  let session: WasmSessionPort | undefined;
  let identity: WorkerEnvelope | undefined;
  let starting = false;
  scope.onmessage = async (event) => {
    const envelope = validateEnvelope(event.data);
    if (!envelope || envelope.channel !== channel) return;
    try {
      if (envelope.kind === "initialize" && !session && !starting) {
        starting = true;
        identity = envelope;
        session = await loadSession(envelope.payload);
        scope.postMessage({ ...envelope, kind: "ready", payload: "null", projection: "null" });
      } else if (sameSession(identity, envelope) && session) {
        handleCall(scope, session, envelope);
      } else throw new Error("Worker is not ready");
    } catch (error) {
      scope.postMessage({ ...envelope, kind: "failure", payload: String(error) });
    }
  };
}

async function loadSession(url: string): Promise<WasmSessionPort> {
  const module = await import(url);
  await module.default();
  return new module.WasmSession();
}

function sameSession(identity: WorkerEnvelope | undefined, envelope: WorkerEnvelope): boolean {
  return identity?.session === envelope.session && identity.generation === envelope.generation;
}

function handleCall(scope: WorkerScope, session: WasmSessionPort, envelope: WorkerEnvelope): void {
  if (envelope.kind === "close") {
    session.free();
    scope.close();
    return;
  }
  if (envelope.kind !== "call" || !envelope.operation) throw new Error("Unsupported Worker operation");
  const answer = JSON.parse(session.callProjected(envelope.operation, envelope.payload)) as {
    response_json: string; projection_json: string;
  };
  scope.postMessage({ ...envelope, kind: "result", payload: answer.response_json, projection: answer.projection_json });
}
