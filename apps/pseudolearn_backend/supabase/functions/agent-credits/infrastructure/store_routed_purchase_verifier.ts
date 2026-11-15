import type { PurchaseClaim, PurchaseVerifier, VerifiedPurchase } from "../domain/purchase.ts";

export class StoreRoutedPurchaseVerifier implements PurchaseVerifier {
  constructor(private readonly verifiers: ReadonlyMap<string, PurchaseVerifier>) {}

  verify(claim: PurchaseClaim, userId: string): Promise<VerifiedPurchase | null> {
    const verifier = this.verifiers.get(claim.store);
    return verifier === undefined ? Promise.resolve(null) : verifier.verify(claim, userId);
  }
}
