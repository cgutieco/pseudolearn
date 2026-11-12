import type { DebugMessage } from "../../src/contracts/debug_session";

interface AdapterLike {
  onDidSendMessage: (listener: (message: DebugMessage) => void) => unknown;
  handleMessage(message: DebugMessage): void;
}

export class AdapterClient {
  private sequence = 0;
  private readonly requests = new Map<number, { resolve: (body: unknown) => void; reject: (error: Error) => void }>();
  private readonly events: DebugMessage[] = [];
  private waiters: Array<{ name: string; resolve: (event: DebugMessage) => void }> = [];
  readonly transcript: DebugMessage[] = [];
  onEvent?: (event: DebugMessage) => void;

  constructor(private readonly adapter: AdapterLike) {
    adapter.onDidSendMessage((message) => this.accept(message));
  }

  request(command: string, argumentsValue: Record<string, unknown> = {}): Promise<any> {
    const seq = ++this.sequence;
    const message = { seq, type: "request", command, arguments: argumentsValue };
    this.transcript.push(message);
    return new Promise((resolve, reject) => {
      this.requests.set(seq, { resolve, reject });
      this.adapter.handleMessage(message);
    });
  }

  waitEvent(name: string): Promise<any> {
    const index = this.events.findIndex((event) => event.event === name);
    if (index >= 0) return Promise.resolve(this.events.splice(index, 1)[0]);
    return new Promise((resolve) => this.waiters.push({ name, resolve }));
  }

  private accept(message: DebugMessage): void {
    this.transcript.push(message);
    if (message.type === "response") {
      const pending = this.requests.get(message.request_seq as number);
      this.requests.delete(message.request_seq as number);
      if (message.success) pending?.resolve(message.body ?? {});
      else pending?.reject(new Error(String(message.message ?? "DAP request failed")));
      return;
    }
    const index = this.waiters.findIndex((waiter) => waiter.name === message.event);
    if (index < 0) this.events.push(message);
    else this.waiters.splice(index, 1)[0]!.resolve(message);
    this.onEvent?.(message);
  }
}
