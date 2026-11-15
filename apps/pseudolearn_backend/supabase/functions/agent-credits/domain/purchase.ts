import {
  milliPerCredit,
  planCredits,
  planDays,
  topUpCredits,
  trialCredits,
  trialDays,
} from "../../agent-responses/domain/credits.ts";

export type Product = "trial" | "monthly" | "top_up";

export type StoreName = "simulated" | "app_store" | "paddle";

export interface ProductTerms {
  readonly milli: number;
  readonly days: number;
}

export const productCatalog: Readonly<Record<Product, ProductTerms>> = {
  trial: { milli: trialCredits * milliPerCredit, days: trialDays },
  monthly: { milli: planCredits * milliPerCredit, days: planDays },
  top_up: { milli: topUpCredits * milliPerCredit, days: 0 },
};

export const storeProductIds: Readonly<Record<string, Product>> = {
  "pseudolearn.nodo.trial": "trial",
  "pseudolearn.nodo.monthly": "monthly",
  "pseudolearn.nodo.topup150": "top_up",
};

export interface PurchaseClaim {
  readonly store: string;
  readonly productId: string;
  readonly transactionId: string;
  readonly evidence: string;
}

export interface VerifiedPurchase {
  readonly store: StoreName;
  readonly product: Product;
  readonly transactionId: string;
  readonly originalTransactionId: string | null;
  readonly startsAt: Date | null;
  readonly endsAt: Date | null;
  readonly trial: boolean;
  readonly revoked: boolean;
  readonly accountToken: string | null;
  readonly customerId: string | null;
}

export interface PurchaseVerifier {
  verify(claim: PurchaseClaim, userId: string): Promise<VerifiedPurchase | null>;
}

export function productOf(productId: string): Product | null {
  return storeProductIds[productId] ?? null;
}

export function simulatedPurchase(
  product: Product,
  transactionId: string,
): VerifiedPurchase {
  return {
    store: "simulated",
    product,
    transactionId,
    originalTransactionId: null,
    startsAt: null,
    endsAt: null,
    trial: product === "trial",
    revoked: false,
    accountToken: null,
    customerId: null,
  };
}
