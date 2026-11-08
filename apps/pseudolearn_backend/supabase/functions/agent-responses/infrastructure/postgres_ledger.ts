import type { AgentErrorCode } from "../domain/agent_error.ts";
import { AgentError } from "../domain/agent_error.ts";
import { type Balance, balanceFrom } from "../domain/balance.ts";
import { callsPerMinute, isRecord, milliPerCredit, requestCapCredits } from "../domain/credits.ts";
import type { Authorization, LedgerCall, LedgerGateway } from "../domain/ports.ts";
import { supabaseTimeoutMilliseconds } from "./fetcher.ts";
import type { SupabaseEndpoint } from "./supabase_user_verifier.ts";

export interface Grant {
  readonly userId: string;
  readonly transactionId: string;
  readonly product: string;
  readonly milli: number;
  readonly days: number;
  readonly now: Date;
}

export type GrantOutcome =
  | { readonly kind: "granted"; readonly balance: Balance; readonly repeated: boolean }
  | { readonly kind: "refused"; readonly code: AgentErrorCode; readonly balance: Balance };

export class PostgresLedger implements LedgerGateway {
  constructor(private readonly endpoint: SupabaseEndpoint) {}

  async authorize(call: LedgerCall): Promise<Authorization> {
    const reply = await this.rpc("agent_authorize", {
      ...this.callArguments(call),
      p_cap_milli: requestCapCredits * milliPerCredit,
      p_calls_per_minute: callsPerMinute,
    });
    const balance = this.balanceOf(isRecord(reply) ? reply.balance : null);
    const error = isRecord(reply) ? reply.error : undefined;
    if (typeof error === "string") {
      return { kind: "refused", code: error as AgentErrorCode, balance };
    }
    return { kind: "authorized", balance };
  }

  async debit(call: LedgerCall, milli: number): Promise<Balance> {
    return this.balanceOf(
      await this.rpc("agent_debit", { ...this.callArguments(call), p_milli: milli }),
    );
  }

  async balance(userId: string, now: Date): Promise<Balance> {
    return this.balanceOf(
      await this.rpc("agent_balance", { p_user: userId, p_now: now.toISOString() }),
    );
  }

  async grant(grant: Grant): Promise<GrantOutcome> {
    const reply = await this.rpc("agent_grant_purchase", {
      p_user: grant.userId,
      p_transaction_id: grant.transactionId,
      p_product: grant.product,
      p_milli: grant.milli,
      p_days: grant.days,
      p_now: grant.now.toISOString(),
    });
    const balance = this.balanceOf(isRecord(reply) ? reply.balance : null);
    const error = isRecord(reply) ? reply.error : undefined;
    if (typeof error === "string") {
      return { kind: "refused", code: error as AgentErrorCode, balance };
    }
    return { kind: "granted", balance, repeated: isRecord(reply) && reply.repeated === true };
  }

  private callArguments(call: LedgerCall): Record<string, unknown> {
    return {
      p_user: call.userId,
      p_request_id: call.requestId,
      p_turn_id: call.turnId,
      p_now: call.now.toISOString(),
    };
  }

  private balanceOf(raw: unknown): Balance {
    const balance = balanceFrom(raw);
    if (balance === null) throw new AgentError("unexpected_failure", "ledger");
    return balance;
  }

  private async rpc(name: string, body: Record<string, unknown>): Promise<unknown> {
    const response = await this.endpoint.fetcher(
      `${this.endpoint.supabaseUrl}/rest/v1/rpc/${name}`,
      {
        method: "POST",
        headers: {
          apikey: this.endpoint.secretKey,
          authorization: `Bearer ${this.endpoint.secretKey}`,
          "content-type": "application/json",
        },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(supabaseTimeoutMilliseconds),
      },
    );
    if (response.status < 200 || response.status >= 300) {
      throw new AgentError("unexpected_failure", `ledger ${response.status}`);
    }
    return await response.json();
  }
}
