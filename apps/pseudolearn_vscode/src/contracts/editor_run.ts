import type { DisposablePort } from "./extension_host";
import type { InterfaceLanguage } from "./extension_configuration";

export type FinishStatus =
  | "completed"
  | "failed"
  | "cancelled"
  | "input_closed"
  | "output_limit"
  | "protocol_error";

export interface RunSource {
  sourceId: number;
  path: string;
}

export type RunEvent =
  | { event: "hello"; schema: number }
  | { event: "output"; text: string }
  | { event: "awaiting_input" }
  | { event: "diagnostics"; diagnostics: unknown[]; projectErrors: unknown[]; sources: RunSource[] }
  | { event: "protocol_error"; reason: string }
  | { event: "finished"; status: FinishStatus; termination: string | null; exitCode: number };

export type RunCommand =
  | { command: "input"; text: string }
  | { command: "cancel" }
  | { command: "close" };

export type RunTarget =
  | { kind: "file"; path: string }
  | { kind: "project"; directory: string; entry: string };

export type RunState =
  | "idle"
  | "starting"
  | "running"
  | "awaitingInput"
  | "stopping"
  | "finished"
  | "aborted"
  | "serverDown";

export interface RunProcessPort {
  onLine(listener: (line: string) => void): void;
  onExit(listener: (code: number | null) => void): void;
  send(line: string): void;
  terminate(): void;
}

export interface ProcessLauncherPort {
  launch(executable: string, argumentsList: string[], workingDirectory: string): RunProcessPort;
}

export interface SchedulerPort {
  after(milliseconds: number, task: () => void): DisposablePort;
}

export interface RunPresenterPort {
  showOutput(text: string): void;
  showDiagnostics(event: Extract<RunEvent, { event: "diagnostics" }>): void;
  showState(state: RunState, language: InterfaceLanguage): void;
  requestInput(language: InterfaceLanguage): Promise<string | undefined>;
  showTechnicalLine(line: string): void;
}

export interface RunSettings {
  executable: string;
  language: InterfaceLanguage;
  profile: "es" | "en";
  strictness: "strict" | "flexible";
}
