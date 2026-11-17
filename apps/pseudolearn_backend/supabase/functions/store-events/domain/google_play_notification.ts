import { isRecord } from "../../agent-responses/domain/credits.ts";
import {
  type GooglePlayCatalog,
  googlePlayOneTimeOf,
  googlePlayOneTimeTransactionId,
  googlePlaySubscriptionEnd,
  googlePlaySubscriptionOf,
} from "../../agent-credits/domain/google_play_purchase.ts";
import { ignored, type StoreEvent } from "./store_event.ts";

export type GooglePlayNotice =
  | { readonly kind: "subscription"; readonly token: string }
  | { readonly kind: "subscription_revoked"; readonly token: string }
  | { readonly kind: "one_time_purchase"; readonly token: string; readonly productId: string }
  | { readonly kind: "voided"; readonly token: string; readonly subscription: boolean }
  | { readonly kind: "ignored"; readonly reason: string };

type Fields = Record<string, unknown>;

const subscriptionRevoked = 12;
const subscriptionPendingPurchaseCanceled = 20;
const oneTimeProductPurchased = 1;
const voidedSubscription = 1;
const endingSubscriptionStates: ReadonlySet<string> = new Set([
  "SUBSCRIPTION_STATE_EXPIRED",
  "SUBSCRIPTION_STATE_ON_HOLD",
  "SUBSCRIPTION_STATE_PAUSED",
]);

export function googlePlayNoticeOf(notification: unknown, packageName: string): GooglePlayNotice {
  if (!isRecord(notification)) return { kind: "ignored", reason: "malformed" };
  if (notification.packageName !== packageName) {
    return { kind: "ignored", reason: "foreign_package" };
  }
  if (isRecord(notification.subscriptionNotification)) {
    return subscriptionNoticeOf(notification.subscriptionNotification);
  }
  if (isRecord(notification.oneTimeProductNotification)) {
    return oneTimeNoticeOf(notification.oneTimeProductNotification);
  }
  if (isRecord(notification.voidedPurchaseNotification)) {
    const voided = notification.voidedPurchaseNotification;
    const token = textOf(voided.purchaseToken);
    if (token === null) return { kind: "ignored", reason: "voided_without_token" };
    return { kind: "voided", token, subscription: voided.productType === voidedSubscription };
  }
  if (isRecord(notification.testNotification)) return { kind: "ignored", reason: "test" };
  return { kind: "ignored", reason: "unsupported_notification" };
}

export function googlePlaySubscriptionEventOf(
  token: string,
  subscription: Fields | null,
  catalog: GooglePlayCatalog,
): StoreEvent {
  if (subscription === null) return ignored("unknown_purchase");
  const state = textOf(subscription.subscriptionState) ?? "";
  if (endingSubscriptionStates.has(state)) {
    const endsAt = googlePlaySubscriptionEnd(subscription);
    if (endsAt === null) return ignored("end_without_date");
    return {
      kind: "subscription_end",
      end: { store: "google_play", originalTransactionId: token, endsAt },
    };
  }
  const purchase = googlePlaySubscriptionOf(token, subscription, catalog);
  if (purchase === null) return ignored(`subscription_${state.toLowerCase()}`);
  return { kind: "purchase", purchase, userHint: purchase.accountToken };
}

export function googlePlayOneTimeEventOf(
  notice: { readonly token: string; readonly productId: string },
  purchase: Fields | null,
  catalog: GooglePlayCatalog,
): StoreEvent {
  if (purchase === null) return ignored("unknown_purchase");
  const verified = googlePlayOneTimeOf(notice.token, notice.productId, purchase, catalog);
  if (verified === null) return ignored("one_time_not_granted");
  return { kind: "purchase", purchase: verified, userHint: verified.accountToken };
}

export function googlePlayRevocationOf(token: string, subscription: boolean): StoreEvent {
  return {
    kind: "revocation",
    revocation: {
      store: "google_play",
      transactionId: subscription ? null : googlePlayOneTimeTransactionId(token),
      originalTransactionId: subscription ? token : null,
    },
  };
}

function subscriptionNoticeOf(notification: Fields): GooglePlayNotice {
  const token = textOf(notification.purchaseToken);
  if (token === null) return { kind: "ignored", reason: "subscription_without_token" };
  if (notification.notificationType === subscriptionRevoked) {
    return { kind: "subscription_revoked", token };
  }
  if (notification.notificationType === subscriptionPendingPurchaseCanceled) {
    return { kind: "ignored", reason: "pending_purchase_canceled" };
  }
  return { kind: "subscription", token };
}

function oneTimeNoticeOf(notification: Fields): GooglePlayNotice {
  const token = textOf(notification.purchaseToken);
  const productId = textOf(notification.sku);
  if (token === null || productId === null) {
    return { kind: "ignored", reason: "one_time_incomplete" };
  }
  if (notification.notificationType !== oneTimeProductPurchased) {
    return { kind: "ignored", reason: "one_time_canceled" };
  }
  return { kind: "one_time_purchase", token, productId };
}

function textOf(value: unknown): string | null {
  return typeof value === "string" && value.length > 0 ? value : null;
}
