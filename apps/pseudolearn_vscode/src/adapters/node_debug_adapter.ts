import { spawn, type ChildProcessWithoutNullStreams } from "node:child_process";
import * as vscode from "vscode";

export class NodeDebugAdapter implements vscode.DebugAdapter {
  private readonly messages = new vscode.EventEmitter<vscode.DebugProtocolMessage>();
  readonly onDidSendMessage = this.messages.event;
  private readonly child: ChildProcessWithoutNullStreams;
  private pending = Buffer.alloc(0);
  private disposed = false;
  private closed = false;
  private terminated = false;

  constructor(executable: string, argumentsList: string[], directory: string | undefined) {
    this.child = spawn(executable, argumentsList, { cwd: directory, env: {}, shell: false, stdio: "pipe" });
    this.child.stdout.on("data", (chunk: Buffer) => this.receive(chunk));
    this.child.stderr.resume();
    this.child.stdin.on("error", () => this.dispose());
    this.child.on("error", () => this.finish());
    this.child.on("close", () => { this.closed = true; this.finish(); });
  }

  handleMessage(message: vscode.DebugProtocolMessage): void {
    if (this.disposed || !this.child.stdin.writable) return;
    const payload = Buffer.from(JSON.stringify(message), "utf8");
    if (payload.length > 8 * 1024 * 1024) {
      this.dispose();
      return;
    }
    this.child.stdin.write(`Content-Length: ${payload.length}\r\n\r\n`);
    this.child.stdin.write(payload);
  }

  dispose(): void {
    if (this.disposed) return;
    this.disposed = true;
    this.child.stdin.destroy();
    if (!this.closed) {
      this.child.kill("SIGTERM");
      const timer = setTimeout(() => this.child.kill("SIGKILL"), 5000);
      timer.unref();
      this.child.once("close", () => clearTimeout(timer));
    }
    this.messages.dispose();
  }

  private receive(chunk: Buffer): void {
    if (this.pending.length + chunk.length > 8 * 1024 * 1024 + 8192) {
      this.dispose();
      return;
    }
    this.pending = Buffer.concat([this.pending, chunk]);
    try {
      while (this.readMessage()) {}
    } catch {
      this.dispose();
    }
  }

  private readMessage(): boolean {
    const boundary = this.pending.indexOf("\r\n\r\n");
    if (boundary < 0) {
      if (this.pending.length > 8192) throw new Error("Debug header limit");
      return false;
    }
    if (boundary > 8192) throw new Error("Debug header limit");
    const lengths = this.pending.subarray(0, boundary).toString("ascii").split("\r\n")
      .filter((line) => /^content-length:/i.test(line));
    if (lengths.length !== 1 || !/^content-length: *[0-9]+$/i.test(lengths[0] ?? "")) {
      throw new Error("Debug framing");
    }
    const length = Number((lengths[0] ?? "").split(":")[1]?.trim());
    if (!Number.isSafeInteger(length) || length > 8 * 1024 * 1024) throw new Error("Debug body limit");
    const end = boundary + 4 + length;
    if (this.pending.length < end) return false;
    const message = JSON.parse(this.pending.subarray(boundary + 4, end).toString("utf8")) as vscode.DebugProtocolMessage;
    if ((message as { event?: string }).event === "terminated") this.terminated = true;
    this.pending = this.pending.subarray(end);
    this.messages.fire(message);
    return true;
  }

  private finish(): void {
    if (!this.disposed && !this.terminated) {
      this.messages.fire({ seq: 0, type: "event", event: "terminated", body: { restart: false } } as vscode.DebugProtocolMessage);
    }
    this.dispose();
  }
}
