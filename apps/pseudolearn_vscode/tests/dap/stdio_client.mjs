import { spawn } from "node:child_process";

export class StdioClient {
  constructor(executable, argumentsList = []) {
    this.sequence = 0;
    this.requests = new Map();
    this.events = [];
    this.waiters = [];
    this.transcript = [];
    this.buffer = Buffer.alloc(0);
    this.child = spawn(executable, ["dap", ...argumentsList], { env: {}, shell: false, stdio: "pipe" });
    this.child.stdout.on("data", (chunk) => this.receive(chunk));
    this.child.stderr.resume();
    this.child.stdin.on("error", () => undefined);
    this.child.on("error", (error) => this.fail(error));
    this.closed = new Promise((resolve) => this.child.once("close", (code) => {
      this.fail(new Error(`DAP closed with ${code}`));
      resolve(code);
    }));
  }

  request(command, argumentsList = {}) {
    const sequence = ++this.sequence;
    const message = { seq: sequence, type: "request", command, arguments: argumentsList };
    const payload = Buffer.from(JSON.stringify(message));
    this.transcript.push({ direction: "request", message });
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => { this.requests.delete(sequence); reject(new Error(`DAP timeout ${command}`)); }, 20000);
      this.requests.set(sequence, { resolve, reject, timer });
      this.child.stdin.write(`Content-Length: ${payload.length}\r\n\r\n`);
      this.child.stdin.write(payload);
    });
  }

  waitEvent(name) {
    const index = this.events.findIndex((event) => event.event === name);
    if (index >= 0) return Promise.resolve(this.events.splice(index, 1)[0]);
    return new Promise((resolve, reject) => {
      const waiter = { name, resolve, reject };
      waiter.timer = setTimeout(() => {
        this.waiters = this.waiters.filter((found) => found !== waiter);
        reject(new Error(`DAP timeout event ${name}`));
      }, 20000);
      this.waiters.push(waiter);
    });
  }

  receive(chunk) {
    this.buffer = Buffer.concat([this.buffer, chunk]);
    try {
      while (this.readMessage()) {}
    } catch (error) { this.fail(error); this.child.kill(); }
  }

  readMessage() {
    const boundary = this.buffer.indexOf("\r\n\r\n");
    if (boundary < 0) {
      if (this.buffer.length > 8192) throw new Error("DAP header exceeds 8 KiB");
      return false;
    }
    const header = this.buffer.subarray(0, boundary).toString("ascii");
    const lengths = [...header.matchAll(/^Content-Length: *([0-9]+)$/gim)];
    if (boundary > 8192 || lengths.length !== 1) throw new Error("DAP invalid framing");
    const length = Number(lengths[0][1]);
    if (!Number.isSafeInteger(length) || length > 8 * 1024 * 1024) throw new Error("DAP body limit");
    const end = boundary + 4 + length;
    if (this.buffer.length < end) return false;
    const message = JSON.parse(this.buffer.subarray(boundary + 4, end).toString("utf8"));
    this.buffer = this.buffer.subarray(end);
    this.accept(message);
    return true;
  }

  accept(message) {
    this.transcript.push({ direction: "response", message });
    if (message.type === "response") {
      const pending = this.requests.get(message.request_seq);
      if (!pending) return;
      clearTimeout(pending.timer);
      this.requests.delete(message.request_seq);
      if (message.success) pending.resolve(message.body ?? {});
      else pending.reject(new Error(message.message ?? "DAP request failed"));
      return;
    }
    if (message.type !== "event") throw new Error("DAP invalid message kind");
    const index = this.waiters.findIndex((waiter) => waiter.name === message.event);
    if (index < 0) this.events.push(message);
    else {
      const waiter = this.waiters.splice(index, 1)[0];
      clearTimeout(waiter.timer);
      waiter.resolve(message);
    }
    this.onEvent?.(message);
  }

  fail(error) {
    for (const pending of this.requests.values()) { clearTimeout(pending.timer); pending.reject(error); }
    for (const waiter of this.waiters) { clearTimeout(waiter.timer); waiter.reject(error); }
    this.requests.clear();
    this.waiters = [];
  }

  async stop() {
    if (this.child.exitCode !== null) return;
    const timer = setTimeout(() => this.child.kill("SIGKILL"), 5000);
    try { await this.request("disconnect"); await this.closed; }
    finally { clearTimeout(timer); if (this.child.exitCode === null) this.child.kill("SIGKILL"); }
  }
}
