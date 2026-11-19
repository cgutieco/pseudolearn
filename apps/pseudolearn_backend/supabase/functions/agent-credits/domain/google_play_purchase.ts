import { isRecord } from "../../agent-responses/domain/credits.ts";
import { productOf, type VerifiedPurchase } from "./purchase.ts";

export interface GooglePlayCatalog {
  readonly packageName: string;
  readonly acceptsTestPurchases: boolean;
}

export const googlePlayStore = "google_play";

export interface GooglePlayPurchases {
  subscription(purchaseToken: string): Promise<Record<string, unknown> | null>;
  oneTimeProduct(productId: string, purchaseToken: string): Promise<Record<string, unknown> | null>;
}

type Fields = Record<string, unknown>;

const entitledSubscriptionStates: ReadonlySet<string> = new Set([
  "SUBSCRIPTION_STATE_ACTIVE",
  "SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
  "SUBSCRIPTION_STATE_CANCELED",
]);
const purchasedOneTimeState = 0;
const testOneTimePurchaseType = 0;

export function googlePlaySubscriptionOf(
  token: string,
  subscription: Fields,
  catalog: GooglePlayCatalog,
): VerifiedPurchase | null {
  const item = monthlyLineItemOf(subscription);
  const grantedAt = dateOf(subscription.startTime);
  const endsAt = item === null ? null : dateOf(item.expiryTime);
  if (item === null || grantedAt === null || endsAt === null) return null;
  if (!entitledSubscriptionStates.has(textOf(subscription.subscriptionState) ?? "")) return null;
  if (isRecord(subscription.testPurchase) && !catalog.acceptsTestPurchases) return null;
  const order = textOf(item.latestSuccessfulOrderId);
  return {
    store: googlePlayStore,
    product: "monthly",
    transactionId: `${googlePlayStore}:${order ?? `${token}:${endsAt.toISOString()}`}`,
    originalTransactionId: token,
    startsAt: null,
    endsAt,
    trial: isRecord(item.offerPhase) && isRecord(item.offerPhase.freeTrial),
    revoked: false,
    accountToken: accountOf(subscription.externalAccountIdentifiers),
    customerId: null,
  };
}

export function googlePlayOneTimeOf(
  token: string,
  productId: string,
  purchase: Fields,
  catalog: GooglePlayCatalog,
): VerifiedPurchase | null {
  if (productOf(productId) !== "top_up") return null;
  if (purchase.purchaseState !== purchasedOneTimeState) return null;
  if (purchase.purchaseType === testOneTimePurchaseType && !catalog.acceptsTestPurchases) {
    return null;
  }
  return {
    store: googlePlayStore,
    product: "top_up",
    transactionId: googlePlayOneTimeTransactionId(token),
    originalTransactionId: null,
    startsAt: null,
    endsAt: null,
    trial: false,
    revoked: false,
    accountToken: textOf(purchase.obfuscatedExternalAccountId),
    customerId: null,
  };
}

export function googlePlayOneTimeTransactionId(token: string): string {
  return `${googlePlayStore}:${token}`;
}

export function googlePlaySubscriptionEnd(subscription: Fields): Date | null {
  const item = monthlyLineItemOf(subscription);
  return item === null ? null : dateOf(item.expiryTime);
}

function monthlyLineItemOf(subscription: Fields): Fields | null {
  const items = Array.isArray(subscription.lineItems) ? subscription.lineItems : [];
  const item = items.find((entry) =>
    isRecord(entry) && productOf(textOf(entry.productId) ?? "") === "monthly"
  );
  return isRecord(item) ? item : null;
}

function accountOf(identifiers: unknown): string | null {
  return isRecord(identifiers) ? textOf(identifiers.obfuscatedExternalAccountId) : null;
}

function textOf(value: unknown): string | null {
  return typeof value === "string" && value.length > 0 ? value : null;
}

function dateOf(value: unknown): Date | null {
  if (typeof value !== "string") return null;
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date;
}
