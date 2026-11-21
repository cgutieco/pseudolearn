import {
  type GooglePlayCatalog,
  googlePlayOneTimeOf,
  type GooglePlayPurchases,
  googlePlayStore,
  googlePlaySubscriptionOf,
} from "../domain/google_play_purchase.ts";
import {
  productOf,
  type PurchaseClaim,
  type PurchaseVerifier,
  type VerifiedPurchase,
} from "../domain/purchase.ts";

export class GooglePlayPurchaseVerifier implements PurchaseVerifier {
  constructor(
    private readonly publisher: GooglePlayPurchases,
    private readonly catalog: GooglePlayCatalog,
  ) {}

  async verify(claim: PurchaseClaim): Promise<VerifiedPurchase | null> {
    if (claim.store !== googlePlayStore || claim.evidence.length === 0) return null;
    const product = productOf(claim.productId);
    if (product === "monthly") {
      const subscription = await this.publisher.subscription(claim.evidence);
      return subscription === null
        ? null
        : googlePlaySubscriptionOf(claim.evidence, subscription, this.catalog);
    }
    if (product !== "top_up") return null;
    const purchase = await this.publisher.oneTimeProduct(claim.productId, claim.evidence);
    return purchase === null
      ? null
      : googlePlayOneTimeOf(claim.evidence, claim.productId, purchase, this.catalog);
  }
}
