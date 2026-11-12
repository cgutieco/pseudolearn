import type { DisposablePort, ExtensionHostPort, LifecycleResult } from "../contracts/extension_host";

export class ExtensionLifecycle {
  private registration: DisposablePort | undefined;

  constructor(private readonly host: ExtensionHostPort) {}

  activate(): LifecycleResult {
    if (this.registration) {
      return { ok: true };
    }
    try {
      this.registration = this.host.registerLifecycle();
      return { ok: true };
    } catch {
      return { ok: false, failure: "registrationFailed" };
    }
  }

  deactivate(): LifecycleResult {
    const registration = this.registration;
    this.registration = undefined;
    if (!registration) {
      return { ok: true };
    }
    try {
      registration.dispose();
      return { ok: true };
    } catch {
      return { ok: false, failure: "cleanupFailed" };
    }
  }
}
