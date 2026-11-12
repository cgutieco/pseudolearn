import { describe, expect, it } from "vitest";
import { ClientLifecycle, maximumConsecutiveStarts } from "../../src/application/client_lifecycle";
import type { ExplainAnswer, LanguageClientFactoryPort, LanguageClientPort } from "../../src/contracts/language_client";

class FakeClient implements LanguageClientPort {
  stopped = 0;
  constructor(private readonly failStart: boolean, private readonly failStop: boolean) {}
  async start(): Promise<void> { if (this.failStart) throw new Error("start"); }
  async stop(): Promise<void> { this.stopped += 1; if (this.failStop) throw new Error("stop"); }
  async explain(): Promise<ExplainAnswer> { return { kind: "none" }; }
}

function factory(failStart = false, failStop = false) {
  const created: FakeClient[] = [];
  const port: LanguageClientFactoryPort = {
    create: () => {
      const client = new FakeClient(failStart, failStop);
      created.push(client);
      return client;
    },
  };
  return { port, created };
}

describe("ClientLifecycle", () => {
  it("starts once and ignores repeated starts", async () => {
    const { port, created } = factory();
    const lifecycle = new ClientLifecycle(port, "pseudo");
    expect(await lifecycle.start()).toBe("running");
    expect(await lifecycle.start()).toBe("running");
    expect(created).toHaveLength(1);
  });

  it("stops repeatedly without stopping twice and tolerates a failing stop", async () => {
    const { port, created } = factory(false, true);
    const lifecycle = new ClientLifecycle(port, "pseudo");
    await lifecycle.start();
    await lifecycle.stop();
    await lifecycle.stop();
    expect(created[0]!.stopped).toBe(1);
    expect(lifecycle.state).toBe("stopped");
  });

  it("gives up after the maximum consecutive failed starts", async () => {
    const { port, created } = factory(true);
    const lifecycle = new ClientLifecycle(port, "pseudo");
    for (let attempt = 0; attempt < maximumConsecutiveStarts + 2; attempt += 1) {
      await lifecycle.start();
    }
    expect(created).toHaveLength(maximumConsecutiveStarts);
    expect(lifecycle.state).toBe("failed");
  });

  it("restart resets the failure budget and starts a fresh client", async () => {
    const { port, created } = factory();
    const lifecycle = new ClientLifecycle(port, "pseudo");
    await lifecycle.start();
    expect(await lifecycle.restart()).toBe("running");
    expect(created).toHaveLength(2);
    expect(created[0]!.stopped).toBe(1);
  });
});
