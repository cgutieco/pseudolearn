import { describe, expect, it } from "vitest";
import { acceptAnswer } from "../../src/application/wire_projection";
import type { WireAnswer } from "../../src/contracts/worker_transport";

const answer = (projection: unknown): WireAnswer => ({ response: JSON.stringify(projection), projection: projection as never });

describe("API acknowledgement", () => {
  it("accepts a null success value", () => {
    expect(() => acceptAnswer(answer({ value: null }))).not.toThrow();
  });

  it("rejects a failure or an absent success field", () => {
    expect(() => acceptAnswer(answer({ failure: { family: "usage", detail: "wrong identity" } }))).toThrow("wrong identity");
    expect(() => acceptAnswer(answer({}))).toThrow("Missing API answer value");
  });
});
