export interface DisposablePort {
  dispose(): void;
}

export interface ExtensionHostPort {
  registerLifecycle(): DisposablePort;
}

export type LifecycleFailure = "registrationFailed" | "cleanupFailed";

export type LifecycleResult =
  | { ok: true }
  | { ok: false; failure: LifecycleFailure };
