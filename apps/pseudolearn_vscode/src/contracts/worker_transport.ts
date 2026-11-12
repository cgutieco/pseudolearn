export type WorkerChannel = "language" | "execution";
export type WorkerKind = "initialize" | "ready" | "call" | "result" | "failure" | "close";

export interface WorkerEnvelope {
  schema: 1;
  channel: WorkerChannel;
  session: string;
  generation: number;
  request: number;
  kind: WorkerKind;
  operation?: string;
  payload: string;
  projection?: string;
}

export type Projection = null | boolean | string | Projection[] | { [name: string]: Projection };

export interface WireAnswer {
  response: string;
  projection: Projection;
}

export interface ApiPort {
  call(operation: string, argumentsJson: string): Promise<WireAnswer>;
  close(): void;
}

export interface WasmSessionPort {
  call(operation: string, argumentsJson: string): string;
  callProjected(operation: string, argumentsJson: string): string;
  free(): void;
}
