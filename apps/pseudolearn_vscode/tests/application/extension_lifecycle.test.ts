import { describe, expect, it } from "vitest";
import { ExtensionLifecycle } from "../../src/application/extension_lifecycle";
import type { DisposablePort, ExtensionHostPort } from "../../src/contracts/extension_host";

describe("ExtensionLifecycle", () => {
  it("registers one lifecycle resource across repeated activation", () => {
    const host = new FakeExtensionHost();
    const lifecycle = new ExtensionLifecycle(host);

    expect(lifecycle.activate()).toEqual({ ok: true });
    expect(lifecycle.activate()).toEqual({ ok: true });
    expect(host.registrations).toBe(1);
  });

  it("returns a typed failure when activation registration fails", () => {
    const host = new FakeExtensionHost(true);
    const lifecycle = new ExtensionLifecycle(host);

    expect(lifecycle.activate()).toEqual({ ok: false, failure: "registrationFailed" });
    expect(lifecycle.deactivate()).toEqual({ ok: true });
  });

  it("deactivates repeatedly without disposing twice", () => {
    const host = new FakeExtensionHost();
    const lifecycle = new ExtensionLifecycle(host);

    lifecycle.activate();

    expect(lifecycle.deactivate()).toEqual({ ok: true });
    expect(lifecycle.deactivate()).toEqual({ ok: true });
    expect(host.disposals).toBe(1);
  });

  it("reports cleanup failures as values", () => {
    const host = new FakeExtensionHost(false, true);
    const lifecycle = new ExtensionLifecycle(host);

    lifecycle.activate();

    expect(lifecycle.deactivate()).toEqual({ ok: false, failure: "cleanupFailed" });
    expect(lifecycle.deactivate()).toEqual({ ok: true });
  });
});

class FakeExtensionHost implements ExtensionHostPort {
  registrations = 0;
  disposals = 0;

  constructor(
    private readonly failRegistration = false,
    private readonly failDisposal = false,
  ) {}

  registerLifecycle(): DisposablePort {
    this.registrations += 1;
    if (this.failRegistration) {
      throw new Error("registration failed");
    }
    return {
      dispose: () => {
        this.disposals += 1;
        if (this.failDisposal) {
          throw new Error("cleanup failed");
        }
      },
    };
  }
}
