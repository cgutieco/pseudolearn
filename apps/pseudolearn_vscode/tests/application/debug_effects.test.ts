import { describe, expect, it } from "vitest";
import { DebugEffectQueue } from "../../src/application/debug_effects";

describe("DebugEffectQueue", () => {
  it("submits each sequence once and hands back completed replies", async () => {
    let closed = false;
    const queue = new DebugEffectQueue({ perform: async () => ({ outcome: "committed" }), close: () => { closed = true; } });
    expect(queue.submit({ effect_seq: "1", operation: "clock_now" })).toBe(true);
    expect(queue.submit({ effect_seq: "1", operation: "clock_now" })).toBe(false);
    expect(queue.isPending()).toBe(true);
    await queue.settle();
    expect(queue.take()).toEqual([{ sequence: "1", result: { outcome: "committed" } }]);
    expect(queue.isPending()).toBe(false);
    queue.close();
    expect(closed).toBe(true);
    expect(queue.submit({ effect_seq: "2" })).toBe(false);
  });

  it("turns a failed provider into an uncertain interruption and rejects missing sequences", async () => {
    const queue = new DebugEffectQueue({ perform: async () => { throw new Error("lost"); }, close: () => undefined });
    expect(() => queue.submit({ operation: "x" })).toThrow("missing effect sequence");
    queue.submit({ effect_seq: "5" });
    await queue.settle();
    expect(queue.take()[0]?.result).toEqual({ outcome: "uncertain", value: { kind: "error", value: "interrumpido" } });
    await queue.settle();
  });
});
