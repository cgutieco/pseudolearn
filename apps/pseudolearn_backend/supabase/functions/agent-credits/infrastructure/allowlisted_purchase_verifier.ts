import { AgentError } from "../../agent-responses/domain/agent_error.ts";
import type { PurchaseClaim, PurchaseVerifier, VerifiedPurchase } from "../domain/purchase.ts";

export class AllowlistedPurchaseVerifier implements PurchaseVerifier {
  constructor(
    private readonly inner: PurchaseVerifier,
    private readonly allowedUsers: ReadonlySet<string>,
  ) {}

  verify(claim: PurchaseClaim, userId: string): Promise<VerifiedPurchase | null> {
    if (!this.allowedUsers.has(userId)) return Promise.reject(new AgentError("purchases_disabled"));
    return this.inner.verify(claim, userId);
  }
}
