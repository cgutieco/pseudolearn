export interface ExplainRequest {
  uri: string;
  version: number;
  line: number;
  character: number;
}

export type ExplainAnswer =
  | { kind: "help"; text: string }
  | { kind: "none" }
  | { kind: "stale" };

export interface LanguageClientPort {
  start(): Promise<void>;
  stop(timeoutMilliseconds: number): Promise<void>;
  explain(request: ExplainRequest): Promise<ExplainAnswer>;
}

export interface LanguageClientFactoryPort {
  create(executable: string): LanguageClientPort;
}

export type ClientLifecycleState = "stopped" | "starting" | "running" | "failed";

export interface ExplainPresenterPort {
  showHelp(text: string): void;
  showNotice(notice: ExplainNotice): void;
}

export type ExplainNotice = "none" | "stale" | "unavailable";
