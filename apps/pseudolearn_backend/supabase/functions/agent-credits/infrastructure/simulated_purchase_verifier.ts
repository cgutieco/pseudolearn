import {
  productOf,
  type PurchaseClaim,
  type PurchaseVerifier,
  simulatedPurchase,
  type VerifiedPurchase,
} from "../domain/purchase.ts";

export const simulatedStore = "simulated";

export class SimulatedPurchaseVerifier implements PurchaseVerifier {
  verify(claim: PurchaseClaim, userId: string): Promise<VerifiedPurchase | null> {
    const product = productOf(claim.productId);
    if (claim.store !== simulatedStore || product === null) return Promise.resolve(null);
    if (claim.transactionId.length === 0) return Promise.resolve(null);
    const transactionId = product === "trial"
      ? `trial:${userId}`
      : `simulated:${claim.transactionId}`;
    return Promise.resolve(simulatedPurchase(product, transactionId));
  }
}
