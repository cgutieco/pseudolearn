import { describe, expect, it } from "vitest";
import { validateEnvelope, maximumPayloadBytes } from "../../src/application/worker_protocol";
import { encodeArguments, numeric } from "../../src/application/canonical_arguments";
import { parseProjection } from "../../src/application/wire_projection";

describe("Worker protocol", () => {
  it("accepts opaque integer payloads without rounding", () => {
    const payload = '{"seed":18446744073709551615,"value":-9223372036854775808}';
    const envelope = { schema: 1, channel: "execution", session: "a", generation: 1,
      request: 1, kind: "call", operation: "start", payload };
    expect(validateEnvelope(envelope)).toEqual(envelope);
    expect(encodeArguments({ seed: numeric("18446744073709551615") })).toBe('{"seed":18446744073709551615}');
  });

  it("rejects unknown schemas and oversized payloads", () => {
    expect(validateEnvelope({ schema: 2 })).toBeUndefined();
    expect(validateEnvelope({ schema: 1, channel: "execution", session: "a", generation: 1,
      request: 1, kind: "call", payload: "x".repeat(maximumPayloadBytes + 1) })).toBeUndefined();
  });

  it("rejects noncanonical numbers and preserves strings", () => {
    expect(() => numeric("01")).toThrow();
    expect(encodeArguments({ text: "9223372036854775807", resource: numeric("1") }))
      .toBe('{"text":"9223372036854775807","resource":1}');
    expect(parseProjection('{"value":"18446744073709551615"}')).toEqual({ value: "18446744073709551615" });
    expect(() => parseProjection('{"value":18446744073709551615}')).toThrow();
  });
});
