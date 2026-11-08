import {
  milliPerCredit,
  planCredits,
  planDays,
  topUpCredits,
  trialCredits,
  trialDays,
} from "../../agent-responses/domain/credits.ts";

export type Product = "trial" | "monthly" | "top_up";

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
  "pseudolearn.plus.trial": "trial",
  "pseudolearn.plus.monthly": "monthly",
  "pseudolearn.plus.topup150": "top_up",
};

export interface PurchaseClaim {
  readonly store: string;
  readonly productId: string;
  readonly transactionId: string;
  readonly evidence: string;
}

export interface VerifiedPurchase {
  readonly product: Product;
  readonly transactionId: string;
}

export interface PurchaseVerifier {
  verify(claim: PurchaseClaim, userId: string): Promise<VerifiedPurchase | null>;
}

export function productOf(productId: string): Product | null {
  return storeProductIds[productId] ?? null;
}
