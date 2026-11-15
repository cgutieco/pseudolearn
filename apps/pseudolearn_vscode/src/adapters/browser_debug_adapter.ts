import * as vscode from "vscode";
import type { DebugMessage } from "../contracts/debug_session";
import type { DebugSession } from "../application/debug_session";

export class BrowserDebugAdapter implements vscode.DebugAdapter {
  private readonly messages = new vscode.EventEmitter<vscode.DebugProtocolMessage>();
  readonly onDidSendMessage = this.messages.event;
  private queue: Promise<void> = Promise.resolve();
  private sequence = 0;
  private driving = false;
  private disposed = false;

  constructor(private readonly session: DebugSession, private readonly release: () => void) {}

  handleMessage(message: vscode.DebugProtocolMessage): void {
    void this.serialized(async () => this.emit(await this.session.handle(message as DebugMessage)))
      .then(() => this.drive());
  }

  dispose(): void {
    if (this.disposed) return;
    this.disposed = true;
    void this.serialized(() => this.session.close()).finally(() => {
      this.release();
      this.messages.dispose();
    });
  }

  private async drive(): Promise<void> {
    if (this.driving) return;
    this.driving = true;
    try {
      while (await this.step()) await new Promise<void>((resolve) => setTimeout(resolve, 0));
    } finally {
      this.driving = false;
    }
  }

  private async step(): Promise<boolean> {
    if (this.disposed || this.session.isFinished()) return false;
    const waiting = this.session.waitingForEffect();
    if (waiting) await waiting;
    else if (!this.session.canAdvance()) return false;
    await this.serialized(async () => this.emit(await this.session.pump()));
    return true;
  }

  private serialized(work: () => Promise<void>): Promise<void> {
    const next = this.queue.then(work, work);
    this.queue = next.catch(() => undefined);
    return next;
  }

  private emit(messages: DebugMessage[]): void {
    if (this.disposed) return;
    for (const message of messages) {
      this.sequence += 1;
      this.messages.fire({ ...message, seq: this.sequence } as vscode.DebugProtocolMessage);
    }
  }
}
