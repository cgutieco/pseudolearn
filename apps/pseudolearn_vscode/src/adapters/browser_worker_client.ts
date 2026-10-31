import type { ApiPort, WireAnswer, WorkerChannel, WorkerEnvelope } from "../contracts/worker_transport";
import { maximumPayloadBytes, maximumPendingRequests, validateEnvelope } from "../application/worker_protocol";
import { parseProjection } from "../application/wire_projection";

interface Pending {
  resolve: (answer: WireAnswer) => void;
  reject: (error: Error) => void;
  timeout: ReturnType<typeof setTimeout>;
}

export class BrowserWorkerClient implements ApiPort {
  private readonly pending = new Map<number, Pending>();
  private sequence = 0;
  private closed = false;
  readonly ready: Promise<void>;

  constructor(private readonly worker: Worker, private readonly identity: {
    channel: WorkerChannel; session: string; generation: number; wasm: string;
  }) {
    worker.onmessage = (event) => this.receive(event.data);
    worker.onerror = () => this.fail("Worker failed");
    worker.onmessageerror = () => this.fail("Worker message failed");
    this.ready = this.request("initialize", "", identity.wasm).then(() => undefined);
  }

  async call(operation: string, argumentsJson: string): Promise<WireAnswer> {
    await this.ready;
    return this.request("call", operation, argumentsJson);
  }

  close(): void {
    if (this.closed) return;
    this.fail("Worker closed");
  }

  private request(kind: "call" | "initialize", operation: string, payload: string): Promise<WireAnswer> {
    if (this.closed || this.pending.size >= maximumPendingRequests) return Promise.reject(new Error("Worker unavailable or saturated"));
    if (new TextEncoder().encode(payload).length > maximumPayloadBytes) return Promise.reject(new Error("Worker payload exceeds limit"));
    const request = ++this.sequence;
    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => this.fail("Worker timed out; full resynchronization required"), 30000);
      this.pending.set(request, { resolve, reject, timeout });
      this.worker.postMessage({ schema: 1, channel: this.identity.channel, session: this.identity.session,
        generation: this.identity.generation, request, kind, operation, payload } satisfies WorkerEnvelope);
    });
  }

  private receive(value: unknown): void {
    const envelope = validateEnvelope(value);
    if (!envelope || envelope.session !== this.identity.session || envelope.channel !== this.identity.channel
      || envelope.generation !== this.identity.generation) return;
    if (!["ready", "result", "failure"].includes(envelope.kind)) return;
    const pending = this.pending.get(envelope.request);
    if (!pending) return;
    this.pending.delete(envelope.request);
    clearTimeout(pending.timeout);
    if (envelope.kind === "failure") pending.reject(new Error(envelope.payload));
    else {
      try { pending.resolve({ response: envelope.payload, projection: parseProjection(envelope.projection ?? "null") }); }
      catch { pending.reject(new Error("Invalid Worker projection")); this.fail("Invalid Worker projection"); }
    }
  }

  private fail(reason: string): void {
    this.closed = true;
    for (const pending of this.pending.values()) {
      clearTimeout(pending.timeout);
      pending.reject(new Error(reason));
    }
    this.pending.clear();
    this.worker.terminate();
  }
}
