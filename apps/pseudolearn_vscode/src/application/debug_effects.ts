import type { DebugEffectPort, DebugRecord } from "../contracts/debug_session";

export interface CompletedEffect {
  sequence: string;
  result: unknown;
}

export class DebugEffectQueue {
  private readonly pending = new Map<string, Promise<void>>();
  private readonly completed: CompletedEffect[] = [];
  private closed = false;

  constructor(private readonly port: DebugEffectPort) {}

  submit(effect: DebugRecord): boolean {
    const sequence = effect.effect_seq;
    if (typeof sequence !== "string") throw new Error("missing effect sequence");
    if (this.pending.has(sequence) || this.closed) return false;
    const settled = this.port.perform(effect).then(
      (result) => this.finish(sequence, result),
      () => this.finish(sequence, { outcome: "uncertain", value: { kind: "error", value: "interrumpido" } }),
    );
    this.pending.set(sequence, settled);
    return true;
  }

  take(): CompletedEffect[] {
    return this.completed.splice(0, this.completed.length);
  }

  isPending(): boolean {
    return this.pending.size > 0;
  }

  async settle(): Promise<void> {
    if (this.completed.length > 0 || this.pending.size === 0) return;
    await Promise.race(this.pending.values());
  }

  close(): void {
    this.closed = true;
    this.pending.clear();
    this.completed.length = 0;
    this.port.close();
  }

  private finish(sequence: string, result: unknown): void {
    if (this.closed || !this.pending.delete(sequence)) return;
    this.completed.push({ sequence, result });
  }
}
