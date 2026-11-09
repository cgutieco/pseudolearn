import { productOf, type VerifiedPurchase } from "./purchase.ts";

export interface AppStoreCatalog {
  readonly bundleId: string;
  readonly environments: ReadonlySet<string>;
}

const introductoryOffer = 1;
const freeTrialDiscount = "FREE_TRIAL";

export function appStorePurchaseOf(
  payload: Record<string, unknown>,
  catalog: AppStoreCatalog,
): VerifiedPurchase | null {
  const transactionId = textOf(payload.transactionId);
  const originalTransactionId = textOf(payload.originalTransactionId);
  const product = productOf(textOf(payload.productId) ?? "");
  const purchaseDate = numberOf(payload.purchaseDate);
  if (transactionId === null || originalTransactionId === null || purchaseDate === null) {
    return null;
  }
  if (product === null || product === "trial") return null;
  if (payload.bundleId !== catalog.bundleId) return null;
  if (!catalog.environments.has(textOf(payload.environment) ?? "")) return null;
  const expiresDate = numberOf(payload.expiresDate);
  if (product === "monthly" && expiresDate === null) return null;
  return {
    store: "app_store",
    product,
    transactionId: `app_store:${transactionId}`,
    originalTransactionId: product === "monthly" ? originalTransactionId : null,
    startsAt: product === "monthly" ? new Date(purchaseDate) : null,
    endsAt: expiresDate === null ? null : new Date(expiresDate),
    trial: isFreeTrial(payload),
    revoked: numberOf(payload.revocationDate) !== null,
    accountToken: textOf(payload.appAccountToken),
    customerId: null,
  };
}

function isFreeTrial(payload: Record<string, unknown>): boolean {
  if (payload.offerType !== introductoryOffer) return false;
  return (textOf(payload.offerDiscountType) ?? freeTrialDiscount) === freeTrialDiscount;
}

function textOf(value: unknown): string | null {
  return typeof value === "string" && value.length > 0 ? value : null;
}

function numberOf(value: unknown): number | null {
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}
