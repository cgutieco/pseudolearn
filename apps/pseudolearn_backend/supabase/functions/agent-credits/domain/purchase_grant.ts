import { type Product, productCatalog, type StoreName, type VerifiedPurchase } from "./purchase.ts";
import { milliPerCredit, trialCredits } from "../../agent-responses/domain/credits.ts";

export const renewalGraceHours = 6;

const millisecondsPerHour = 3_600_000;
const millisecondsPerDay = 24 * millisecondsPerHour;

export interface PurchaseGrant {
  readonly userId: string;
  readonly store: StoreName;
  readonly product: Product;
  readonly transactionId: string;
  readonly originalTransactionId: string | null;
  readonly milli: number;
  readonly startsAt: Date;
  readonly endsAt: Date;
  readonly trial: boolean;
  readonly customerId: string | null;
  readonly now: Date;
}

export function purchaseGrantFor(
  userId: string,
  purchase: VerifiedPurchase,
  now: Date,
): PurchaseGrant {
  const terms = productCatalog[purchase.product];
  const startsAt = purchase.startsAt ?? now;
  return {
    userId,
    store: purchase.store,
    product: purchase.product,
    transactionId: purchase.transactionId,
    originalTransactionId: purchase.originalTransactionId,
    milli: purchase.trial ? trialCredits * milliPerCredit : terms.milli,
    startsAt,
    endsAt: endOf(purchase, startsAt, terms.days),
    trial: purchase.trial,
    customerId: purchase.customerId,
    now,
  };
}

function endOf(purchase: VerifiedPurchase, startsAt: Date, days: number): Date {
  if (purchase.endsAt === null) return new Date(startsAt.getTime() + days * millisecondsPerDay);
  return new Date(purchase.endsAt.getTime() + renewalGraceHours * millisecondsPerHour);
}
