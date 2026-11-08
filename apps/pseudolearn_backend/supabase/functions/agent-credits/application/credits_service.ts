import { authenticatedUser } from "../../agent-responses/application/agent_service.ts";
import { AgentError, type AgentErrorCode } from "../../agent-responses/domain/agent_error.ts";
import type { Balance } from "../../agent-responses/domain/balance.ts";
import type { Clock, UserVerifier } from "../../agent-responses/domain/ports.ts";
import { productCatalog, type PurchaseClaim, type PurchaseVerifier } from "../domain/purchase.ts";

export interface PurchaseGrant {
  readonly userId: string;
  readonly transactionId: string;
  readonly product: string;
  readonly milli: number;
  readonly days: number;
  readonly now: Date;
}

export type PurchaseGrantOutcome =
  | { readonly kind: "granted"; readonly balance: Balance; readonly repeated: boolean }
  | { readonly kind: "refused"; readonly code: AgentErrorCode; readonly balance: Balance };

export interface CreditsLedger {
  balance(userId: string, now: Date): Promise<Balance>;
  grant(grant: PurchaseGrant): Promise<PurchaseGrantOutcome>;
}

export interface CreditsDependencies {
  readonly users: UserVerifier;
  readonly ledger: CreditsLedger;
  readonly purchases: PurchaseVerifier | null;
  readonly clock: Clock;
}

export async function readBalance(
  accessToken: string,
  dependencies: CreditsDependencies,
): Promise<Balance> {
  const userId = await authenticatedUser(dependencies.users, accessToken);
  return await dependencies.ledger.balance(userId, dependencies.clock.now());
}

export async function redeemPurchase(
  accessToken: string,
  claim: PurchaseClaim,
  dependencies: CreditsDependencies,
): Promise<{ readonly balance: Balance; readonly repeated: boolean }> {
  const userId = await authenticatedUser(dependencies.users, accessToken);
  if (dependencies.purchases === null) throw new AgentError("purchases_disabled");
  const verified = await dependencies.purchases.verify(claim, userId);
  if (verified === null) throw new AgentError("invalid_request", "purchase");
  const terms = productCatalog[verified.product];
  const outcome = await dependencies.ledger.grant({
    userId,
    transactionId: verified.transactionId,
    product: verified.product,
    milli: terms.milli,
    days: terms.days,
    now: dependencies.clock.now(),
  });
  if (outcome.kind === "refused") throw new AgentError(outcome.code);
  return { balance: outcome.balance, repeated: outcome.repeated };
}
