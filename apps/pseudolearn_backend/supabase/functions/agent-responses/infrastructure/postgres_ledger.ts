import type { AgentErrorCode } from "../domain/agent_error.ts";
import { AgentError } from "../domain/agent_error.ts";
import { type Balance, balanceFrom } from "../domain/balance.ts";
import { callsPerMinute, isRecord, milliPerCredit, requestCapCredits } from "../domain/credits.ts";
import type { Authorization, LedgerCall, LedgerGateway } from "../domain/ports.ts";
import { callRpc } from "./supabase_rpc.ts";
import type { SupabaseEndpoint } from "./supabase_user_verifier.ts";

export class PostgresLedger implements LedgerGateway {
  constructor(private readonly endpoint: SupabaseEndpoint) {}

  async authorize(call: LedgerCall): Promise<Authorization> {
    const reply = await callRpc(this.endpoint, "agent_authorize", {
      ...this.callArguments(call),
      p_cap_milli: requestCapCredits * milliPerCredit,
      p_calls_per_minute: callsPerMinute,
    });
    const balance = ledgerBalanceOf(isRecord(reply) ? reply.balance : null);
    const error = isRecord(reply) ? reply.error : undefined;
    if (typeof error === "string") {
      return { kind: "refused", code: error as AgentErrorCode, balance };
    }
    return { kind: "authorized", balance };
  }

  async debit(call: LedgerCall, milli: number): Promise<Balance> {
    return ledgerBalanceOf(
      await callRpc(this.endpoint, "agent_debit", { ...this.callArguments(call), p_milli: milli }),
    );
  }

  async balance(userId: string, now: Date): Promise<Balance> {
    return ledgerBalanceOf(
      await callRpc(this.endpoint, "agent_balance", { p_user: userId, p_now: now.toISOString() }),
    );
  }

  private callArguments(call: LedgerCall): Record<string, unknown> {
    return {
      p_user: call.userId,
      p_request_id: call.requestId,
      p_turn_id: call.turnId,
      p_now: call.now.toISOString(),
    };
  }
}

export function ledgerBalanceOf(raw: unknown): Balance {
  const balance = balanceFrom(raw);
  if (balance === null) throw new AgentError("unexpected_failure", "ledger");
  return balance;
}
