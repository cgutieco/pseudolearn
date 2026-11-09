import { authenticatedUser } from "../../agent-responses/application/agent_service.ts";
import { AgentError } from "../../agent-responses/domain/agent_error.ts";
import type { Balance } from "../../agent-responses/domain/balance.ts";
import type { Clock, UserVerifier } from "../../agent-responses/domain/ports.ts";
import type { CheckoutGateway } from "../domain/checkout.ts";
import type { PurchaseClaim, PurchaseVerifier, VerifiedPurchase } from "../domain/purchase.ts";
import { purchaseGrantFor } from "../domain/purchase_grant.ts";
import type { StoreLedger } from "../domain/store_ledger.ts";

export interface CreditsDependencies {
  readonly users: UserVerifier;
  readonly ledger: StoreLedger;
  readonly purchases: PurchaseVerifier | null;
  readonly checkouts: CheckoutGateway | null;
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
  if (!belongsTo(verified, userId)) throw new AgentError("purchase_owned_elsewhere");
  const now = dependencies.clock.now();
  if (verified.revoked) {
    await dependencies.ledger.revoke({
      store: verified.store,
      transactionId: verified.transactionId,
      originalTransactionId: null,
      now,
    });
    throw new AgentError("invalid_request", "revoked");
  }
  const outcome = await dependencies.ledger.apply(purchaseGrantFor(userId, verified, now));
  if (outcome.kind === "refused") throw new AgentError(outcome.code);
  return { balance: outcome.balance, repeated: outcome.repeated };
}

function belongsTo(purchase: VerifiedPurchase, userId: string): boolean {
  return purchase.accountToken === null ||
    purchase.accountToken.toLowerCase() === userId.toLowerCase();
}
