import type { AgentErrorCode } from "./agent_error.ts";
import type { Balance } from "./balance.ts";

export interface UserVerifier {
  verify(accessToken: string): Promise<string | null>;
}

export interface LedgerCall {
  readonly userId: string;
  readonly requestId: string;
  readonly turnId: string;
  readonly now: Date;
}

export type Authorization =
  | { readonly kind: "authorized"; readonly balance: Balance }
  | { readonly kind: "refused"; readonly code: AgentErrorCode; readonly balance: Balance };

export interface LedgerGateway {
  authorize(call: LedgerCall): Promise<Authorization>;
  debit(call: LedgerCall, milli: number): Promise<Balance>;
  balance(userId: string, now: Date): Promise<Balance>;
}

export interface ModelReply {
  readonly status: number;
  readonly body: string;
  readonly json: unknown;
  readonly retryAfter: string | null;
}

export interface ModelGateway {
  respond(body: Record<string, unknown>): Promise<ModelReply>;
}

export interface Clock {
  now(): Date;
}
