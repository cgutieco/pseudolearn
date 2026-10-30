import type {
  ClientLifecycleState,
  ExplainAnswer,
  ExplainRequest,
  LanguageClientFactoryPort,
  LanguageClientPort,
} from "../contracts/language_client";

export const maximumConsecutiveStarts = 3;
export const stopTimeoutMilliseconds = 2000;

export class ClientLifecycle {
  private client: LanguageClientPort | undefined;
  private current: ClientLifecycleState = "stopped";
  private failures = 0;

  constructor(
    private readonly factory: LanguageClientFactoryPort,
    private readonly executable: string,
  ) {}

  get state(): ClientLifecycleState {
    return this.current;
  }

  async start(): Promise<ClientLifecycleState> {
    if (this.client || this.failures >= maximumConsecutiveStarts) {
      return this.current;
    }
    this.current = "starting";
    const client = this.factory.create(this.executable);
    this.client = client;
    try {
      await client.start();
      this.current = "running";
      this.failures = 0;
    } catch {
      this.client = undefined;
      this.failures += 1;
      this.current = "failed";
    }
    return this.current;
  }

  async stop(): Promise<void> {
    const client = this.client;
    this.client = undefined;
    this.current = "stopped";
    if (client) {
      try {
        await client.stop(stopTimeoutMilliseconds);
      } catch {
        this.current = "stopped";
      }
    }
  }

  async explain(request: ExplainRequest): Promise<ExplainAnswer | undefined> {
    if (!this.client || this.current !== "running") {
      return undefined;
    }
    try {
      return await this.client.explain(request);
    } catch {
      return undefined;
    }
  }

  async restart(): Promise<ClientLifecycleState> {
    await this.stop();
    this.failures = 0;
    return this.start();
  }
}
